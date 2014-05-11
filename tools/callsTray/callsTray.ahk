#NoEnv 
SendMode Input
#SingleInstance force
#Persistent
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2

#include %A_ScriptDir%\..\_libs\helperFunctions.ahk
#include %A_ScriptDir%\..\_libs\tf.ahk
#include %A_ScriptDir%\..\_libs\Array.ahk

Menu, tray, NoStandard

;on a missed call you can click the icon to turn it green again
OnMessage(0x404, "AHK_NOTIFYICON") 


FileEncoding, UTF-8

ERROR_LIMIT			:= 10

ACTIONURL_RECONNECT = internet/inetstat_monitor.lua?sid={sID}&useajax=0&action=disconnect
ACTIONURL_REBOOT	= system/reboot.lua
ACTIONURL_CALLS 	= fon_num/foncalls_list.lua?sid={sID}
ACTIONURL_CALL		= fon_num/foncalls_list.lua?sid={sID}&dial={phonenumber}&xhr=1&t1399792259462=nocache
ACTIONURL_HANGUP	= fon_num/foncalls_list.lua?sid={sID}&hangup=&xhr=1&t1399795344154=nocache
TMPFILE_PREFIX		= %A_TEMP%\callsTray_

CURL_PATH 			= %A_ScriptDir%\..\_libs\bin\curl.exe


_newMissedCalls				:= false
_newestMissedCallDatetime 	=
_phoneNumbers 				=
_sID						=
_errors						:= 0
_lastCalledNumber			=
_callInProgress 			:= false


_iniFile 							:= helperIniFile()
IniRead, _fritboxUrl,				%_iniFile%, fritzbox, url
IniRead, _fritboxUsername,			%_iniFile%, fritzbox, username
IniRead, _fritboxPassword,			%_iniFile%, fritzbox, password

IniRead, _updateInterval,			%_iniFile%, settings, updateinterval, 10
IniRead, _callstoshow,				%_iniFile%, settings, callstoshow, 10
IniRead, _directcall,				%_iniFile%, settings, directcall, 1
IniRead, _traytiponmissedcall,		%_iniFile%, settings, traytiponmissedcall, 1

_updateInterval 					:= _updateInterval * 1000

GoSub, updateCallList

return

updateCallList:
	if(_callInProgress) return
	
	SetTimer, updateCallList, OFF	
	
	Menu, tray, Icon, callsTray_black.ico
	Menu, tray, DeleteAll
	
	GoSub, downloadCallList
	
	GoSub, createTrayMenu
	
	SetTimer, updateCallList, %_updateInterval%
return

createTrayMenu:	
	cFilepath = %TMPFILE_PREFIX%calls.html
	TF(cFilepath)
	foundPos 	:= TF_Find(T, "", "", "<table id=""uiCalls"" ", 1, 0)
	startLine 	:= foundPos + 1
	;stopLine 	:= foundPos + 520
	cLines 		:= TF_ReadLines(T,startLine)
	;M sgBox, %cLines%
	StringSplit, cArray, cLines, `n  

	_phoneNumbers 				:= Array()
	newestMissedCallDatetime 	= 
	newestMissedCallInfo		=
	counter 					:= 0
	Loop, %cArray0%
	{
		element := cArray%A_Index%
		IfInString, element, class="call_
		{
			; "
			StringReplace, element, element, class=" , |
			StringReplace, element, element, " , |
			StringReplace, element, element, onDial , |				
			;M sgBox, %element%
			
			StringSplit, cArray, element, |
			; "
			cType = %cArray2%
			
			cIndex := A_Index + 1
			cDatetime := helperStripTags(cArray%cIndex%)
			
			cIndex := A_Index + 2
			cCaller := helperStripTags(cArray%cIndex%)
			
			; get the phone number
			cVal := cArray%cIndex%
			StringReplace, cVal, cVal, onDial(' , _
			StringReplace, cVal, cVal, ') , _
			StringSplit, cArray, cVal, _						
			cPhone = %cArray2%
			_phoneNumbers.append(cPhone)			

			;output = %output%`n%cDatetime% - %cType% - %cCaller%
			Menu, tray, add, %cDatetime% - %cCaller% , MenuHandler
			if(cType = "call_in") {
				;Menu, tray, Icon, %cDatetime% - %cCaller%, shell32.dll, 302
				Menu, tray, Icon, %cDatetime% - %cCaller%, callsTray.ico
			} else if(cType = "call_in_fail") {
				if(newestMissedCallDatetime = "") {
					newestMissedCallDatetime 	= %cDatetime%
					newestMissedCallInfo 		= %cCaller%
				}
				Menu, tray, Icon, %cDatetime% - %cCaller%, callsTray_red.ico
			} else if(cType = "call_out") {
				Menu, tray, Icon, %cDatetime% - %cCaller%, shell32.dll, 147
			}			
		
			counter := counter + 1
			if(counter >= _callstoshow) {
				break
			}			
		}

	}
	
	if(_newMissedCalls) {
		Menu, Tray, Icon, callsTray_red.ico
	} else {
		Menu, Tray, Icon, callsTray.ico
	}
	
	;M sgBox, %_newestMissedCallDatetime% - %newestMissedCallDatetime%
	if(_newestMissedCallDatetime != "" && _newestMissedCallDatetime != newestMissedCallDatetime) {
		_newMissedCalls := true
		if(_traytiponmissedcall = 1) {
			TrayTip, Missed call, %newestMissedCallInfo%
		}
		Menu, Tray, Icon, callsTray_red.ico
	}
	_newestMissedCallDatetime = %newestMissedCallDatetime%	
	
	FileDelete, %TMPFILE_PREFIX%calls.html
	GoSub, addDefaultTray
	
return

MenuHandler:
	if(_directcall = 0) return
	
	cPhone := _phoneNumbers[A_ThisMenuItemPos] 
	call(_sID, cPhone)
return

AHK_NOTIFYICON(wParam, lParam) { 
	global _newMissedCalls
	if (lParam = 0x202) ; WM_LBUTTONUP
    { 		
		if(_newMissedCalls) {
			_newMissedCalls := false
			Menu, Tray, Icon, callsTray.ico		
		}
	}
}

call(sID, number) {
	global _lastCalledNumber
	global _callInProgress
	global CURL_PATH
	
	_callInProgress := true
	_lastCalledNumber = %number%
	
	GoSub, showBasicCallGui
	
	global _fritboxUrl
	global ACTIONURL_CALL

	cUrl = %_fritboxUrl%%ACTIONURL_CALL%
	StringReplace, cUrl, cUrl, {sID} , %sID%	
	StringReplace, cUrl, cUrl, {phonenumber} , %number%
	;M sgBox, curl -s -k "%cUrl%"
	RunWait, %CURL_PATH% -s -k "%cUrl%",, hide	
	
	GoSub, showCallGuiWithCancel
}


showBasicCallGui:	
	Gui, Add, Text, vCallText , Calling %_lastCalledNumber% ...
	Gui, Show, w160 h60, Calling
return

showCallGuiWithCancel:	
	Gui, Hide
	Gui, Add, Button, Default gbtnCancelCall, cancel
	Gui, Show, w160 h60, Calling
return

GuiClose:
	Gui, Destroy
	_callInProgress := false
	hangup(_sID)	
return

btnCancelCall:
	Gui, Destroy
	_callInProgress := false
	hangup(_sID)	
return

hangup(sID) {
	global _fritboxUrl
	global ACTIONURL_HANGUP
	global CURL_PATH
	
	cUrl = %_fritboxUrl%%ACTIONURL_HANGUP%
	StringReplace, cUrl, cUrl, {sID} , %sID%
	
	RunWait, %CURL_PATH% -s -k "%cUrl%",,hide
}

getSID:	
	cFilepath = %TMPFILE_PREFIX%loginpage.html
	FileDelete, %cFilepath%
	
	;M sgBox, curl -s -k -o "%cFilepath%" "%_fritboxUrl%login.lua"
	RunWait, %CURL_PATH% -s -k -o "%cFilepath%" "%_fritboxUrl%login.lua",, hide	
	
	TF(cFilepath)

	foundPos := TF_Find(T, "", "", "var g_challenge", 1, 0)
	;M sgBox, %foundPos%
	targetPos := foundPos + 1
	found := TF_Find(T, targetPos, "", "g_challenge = ", 1, 1)
	StringSplit, cArray, found, "
	; "
	cChallenge = %cArray2%
	FileDelete, %cFilepath%

	FileDelete, %TMPFILE_PREFIX%response.txt
	RunWait, %comspec% /c Cscript.exe //NOlogo md5.js "%cChallenge%-%_fritboxPassword%" > "%TMPFILE_PREFIX%response.txt",,hide	
	FileReadLine, cResponse, %TMPFILE_PREFIX%response.txt, 1
	FileDelete, %TMPFILE_PREFIX%response.txt
	
	;M sgBox, %cChallenge%-%_fritboxPassword% | %cResponse%
	;M sgBox, curl -s -i -k -o "%TMPFILE_PREFIX%id.txt" "%_fritboxUrl%login.lua" --data "response=%cChallenge%-%cResponse%&page=&username=%_fritboxUsername%"
	RunWait, %CURL_PATH% -s -i -k -o "%TMPFILE_PREFIX%id.txt" "%_fritboxUrl%login.lua" --data "response=%cChallenge%-%cResponse%&page=&username=%_fritboxUsername%",, hide

	FileReadLine, cDestination, %TMPFILE_PREFIX%id.txt, 3
	;M sgBox, %cDestination%
	StringSplit, cArray, cDestination, %A_SPACE%
	cUrl = %cArray2%
	StringSplit, cArray, cUrl, =
	_sID =  %cArray2%
	FileDelete, %TMPFILE_PREFIX%id.txt
return

downloadCallList:
	if(_errors > ERROR_LIMIT) {
		; abort
		failed()
	}
	if(_sID = "") {
		GoSub, getSID
	}
	;M sgBox, %_sID%
	cUrl = %_fritboxUrl%%ACTIONURL_CALLS%
	StringReplace, cUrl, cUrl, {sID} , %_sID%
	
	cFilepath = %TMPFILE_PREFIX%calls.html
	FileDelete, %cFilepath%
	;M sgBox, curl -o "%TMPFILE_PREFIX%calls.html" -k "%cUrl%"
	RunWait, %CURL_PATH% -o "%cFilepath%" -k "%cUrl%",, hide	

	IfNotExist, %cFilepath%
	{	
		_errors ++
		; maybe the _sID is not working anmyore
		GoSub, getSID
		GoSub, downloadCallList
	}
return

failed() {
	MsgBox, there is something wrong
}

executeUrl(url, sID) {
	global _fritboxUrl 
	global CURL_PATH
	
	StringReplace, cUrl, url, {sID} , %sID%
	RunWait, %CURL_PATH% -s -l -k "%_fritboxUrl%%cUrl%" --data "sid=%cID%",, hide
}

#include %A_ScriptDir%\..\_libs\defaultTray.ahk