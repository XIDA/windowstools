#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
#SingleInstance off
#Persistent

SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2

#include %A_ScriptDir%\..\_libs\helperFunctions.ahk

Menu, tray, NoStandard
;Menu, tray, Icon, ftpUploader.ico,  1
Menu, tray, add  ; Creates a separator line.
Menu, tray, add, Reload  
Menu, tray, add, Exit

_iniFile 					:= helperIniFile()
_curlProcessID				 =
_statusFileCurrentLine 		:= 0
_statusFileCheckInProgress  := false

Random, rand, 1111111, 9999999
_statusFile					= %A_TEMP%\status_ftpUploader_%rand%.log

;load settings from main ini START
;directories
IniRead, curlPath, %_iniFile%, directories, curlDir,
	
;M sgBox, %_settingsIniFile%

;load current backup project settings
IniRead, folder, 			%_iniFile%, ftp, folder
IniRead, ftpHost, 			%_iniFile%, ftp, host
IniRead, ftpUser,			%_iniFile%, ftp, user
IniRead, ftpPass, 			%_iniFile%, ftp, pass

IniRead, baseUrl, 			%_iniFile%, url, base

fileName = 
filePathAndName = %1%
SplitPath, filePathAndName , fileName

StringLen, cLength, fileName
if(cLength > 0) {
	GoSub, handlePath
	return
}

addRegFilename 		= AddToRightClickMenu.reg
removeRegFilename 	= RemoveFromRightClickMenu.reg

IfNotExist, %addRegFilename% 
{
	;create reg file
	FileRead, cContents, regTemplates\%addRegFilename%
	cDir = %A_ScriptDir%
	StringReplace, cDir, cDir, \ , \\, All
	StringReplace, cContents, cContents, {currentfolder} , %cDir%, All
	FileAppend, %cContents%, %addRegFilename%
	;M sgBox, %cContents%
	RunWait, %addRegFilename%
	FileDelete, %addRegFilename%
}

IfNotExist, %removeRegFilename% 
{
	;copy reg file
	FileCopy, regTemplates\%removeRegFilename%, %removeRegFilename%	
}


handlePath:
	
	FileDelete, %_statusFile%
	Run %comspec% /c "%curlPath% -g -T "%filePathAndName%" -u %ftpUser%:%ftpPass% ftp://ftp.%ftpHost% 2> %_statusFile%",, Hide, _curlProcessID

	Gui, Add, Progress, w230 vMyProgress
	Gui, Add, Text, w250 vProgressText, ...
	Gui, Show, w250, ftpUploader
	;Progress, b T w200, ... , Uploading

	SetTimer, checkStatus, 1000
	SetTimer, checkIfProcessIsRunning, 5000
	
return

checkIfProcessIsRunning:
	if(_statusFileCheckInProgress) 
	{
		return
	}
	
	if(!helperProcessExist(_curlProcessID)) {		
		
		FileDelete, %_statusFile%
		ExitApp
	}
return

checkStatus:
	if(_statusFileCheckInProgress) 
	{
		return
	}
	
	_statusFileCheckInProgress := true


	numLines := 0
	Loop
	{
		FileReadLine, line, %_statusFile%, %A_Index%
		if ErrorLevel
			break
		
		numLines ++
	}	
	if(numLines = _statusFileCurrentLine)
	{
		;return
	}
	
	updateStatus(line)
	
	_statusFileCurrentLine := numLines
	
	_statusFileCheckInProgress := false
	
return

updateStatus(line) {
	line = %line%
	StringReplace, line, line, %A_Space%, |, 1
	StringReplace, line, line, |||, |, 1
	StringReplace, line, line, ||, |, 1
	
	StringSplit, cArray, line, |, %A_Space%%A_Tab%
	
	cPercent = %cArray1%

	;Progress, %cArray1%, %cArray7% - %cArray2%
	GuiControl,, MyProgress, %cArray1%
	GuiControl,, ProgressText, %cArray7% - %cArray2% | %cArray10%
	;Gui, Show, , %cArray10%
	
	if(cPercent = 100) {
		global baseUrl
		global fileName
		clipboard = %baseUrl%%fileName%
	}
}
	

GuiClose:
	GoSub, Exit
return
Reload:
	Run %comspec% /c "TaskKill /PID %_curlProcessID% /T /F",, Hide
	FileDelete, %_statusFile%
	Reload
return 

Exit:
	Run %comspec% /c "TaskKill /PID %_curlProcessID% /T /F",, Hide	
	FileDelete, %_statusFile%
	ExitApp
return
