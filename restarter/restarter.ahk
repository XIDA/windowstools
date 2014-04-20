#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
#SingleInstance force

;#NoTrayIcon
Menu, tray, NoStandard
Menu, tray, add  ; Creates a separator line.

SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2

cName := ScriptNameNoExt()

FileReadLine, cProcess, %cName%.txt, 1
FileReadLine, cPath, %cName%.txt, 2

;MsgBox, %cProcess% %cPath%

if(Strlen(cProcess) > 0) {
	TrayTip, %cName%, Closing %cProcess% ...
	Sleep, 1000
	RunWait, %comspec% /c "taskkill /F /IM %cProcess%",,min
}		

if(Strlen(cPath) > 0) {	
	IfExist, %cPath%
	{
		TrayTip, %cName%, Starting %cPath% ...
		Sleep, 1000
		Run, "%cPath%"
	} 
	else
	{
		MsgBox, Could not find %cPath%
	}
}
Sleep, 1000
TrayTip,,

ScriptNameNoExt() {
    SplitPath, A_ScriptName,,,, ScriptNameNoExt
    return ScriptNameNoExt
}

ExitApp
	
