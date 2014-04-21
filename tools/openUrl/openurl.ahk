;
; AutoHotkey Version: 1.x
; Language:       English
; Platform:       Win9x/NT
; Author:         A.N.Other <myemail@nowhere.com>
;
; Script Function:
;	Template script (you can customize this template by editing "ShellNew\Template.ahk" in your Windows folder)
;

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
#SingleInstance force
#Persistent ;Script nicht beenden nach der Auto-Execution-Section
#NoTrayIcon
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2


Menu, tray, NoStandard
Menu, tray, add  ; Creates a separator line.
Menu, tray, add, Reload  
Menu, tray, add, Exit

cName := ScriptNameNoExt()



Loop
{
	FileReadLine, line, %cName%.txt, %A_Index%
	if ErrorLevel
		break
		
	line := replaceSpecialStrings(line)
	;M sgBox, 4, , Line #%A_Index% is "%line%".  Continue?
	
	cUrl = %line%
	Length := StrLen(cUrl)

	if(Length = 0) {
		MsgBox, Url is empty!
		ExitApp
	}
	
	httpQuery(result,cUrl)
	VarSetCapacity(result,-1)   
}



;MsgBox % result
ExitApp
return

Reload:
	Reload
return 

Exit:
	ExitApp
return

if(!A_IsCompiled) {
	#y::
		Send ^s
		reload
	return
}

replaceSpecialStrings(line) {
	;get current date
	FormatTime, TimeString, , dd.MM.yyyy HH:mm
	;M sgBox The current time and date (date first) is %TimeString%.	
	StringReplace, NewStr, line, {datetime}, %TimeString%, All
	
	Random, rand, 11111, 99999
	StringReplace, NewStr, NewStr, {random}, %rand%, All	

	;PC Name
	StringReplace, NewStr, NewStr, {computername}, %A_ComputerName%, All
	
	return NewStr
}

ScriptNameNoExt() {
    SplitPath, A_ScriptName,,,, ScriptNameNoExt
    return ScriptNameNoExt
}

httpQuery(byref Result, lpszUrl, POSTDATA="", HEADERS="")
{
   WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
   WebRequest.Open("POST", lpszUrl)
   WebRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
   WebRequest.Send(POSTDATA)
   Result := WebRequest.ResponseText
   WebRequest := ""
}