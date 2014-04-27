#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
#SingleInstance force
#Persistent ;Script nicht beenden nach der Auto-Execution-Section
#NoTrayIcon
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2

#include ..\_libs\helperFunctions.ahk

Menu, tray, NoStandard
Menu, tray, add  ; Creates a separator line.
Menu, tray, add, Reload  
Menu, tray, add, Exit


;check if there is a command line parameter
if 0 < 1
{
	;if not check the txt file
	executeUrlsFromFile()
	
} else {

	;if there is are command line parameters we iterate over them
	Loop, %0% ; for each parameter
	{
		param := %A_Index%
		exectureUrlFromCommandLine(param)	
		
	}

}

ExitApp
return

Reload:
	Reload
return 

Exit:
	ExitApp
return

exectureUrlFromCommandLine(parameter) {
	url := replaceSpecialStrings(parameter)
	
	httpQuery(result,url)
	VarSetCapacity(result,-1)
}

executeUrlsFromFile() {
	cName := helperScriptNameNoExt()
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

httpQuery(byref Result, lpszUrl, POSTDATA="", HEADERS="")
{
   WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
   WebRequest.Open("POST", lpszUrl)
   WebRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
   WebRequest.Send(POSTDATA)
   Result := WebRequest.ResponseText
   WebRequest := ""
}