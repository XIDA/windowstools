#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
#SingleInstance force
#Persistent ;Script nicht beenden nach der Auto-Execution-Section
#NoTrayIcon
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2

#include %A_ScriptDir%\..\_libs\helperFunctions.ahk

Menu, tray, NoStandard
Menu, tray, add  ; Creates a separator line.
Menu, tray, add, Reload  
Menu, tray, add, Exit

_iniFile 					:= helperIniFile("ftpBackup")
IniRead, backupBaseDir, 	%_iniFile%, directories, backupBaseDir, backup
IniRead, backupInisBaseDir, %_iniFile%, directories, backupInisBaseDir, ""

_oldestFile 		= 0
_oldestTimeStamp 	= 0

Loop, %backupBaseDir%\*., 2 , 1  ; Recurse into subfolders.
{
	cName = %A_LoopFileName%
	if(cName = "current") {
		FileGetTime, lastModifiedTimestamp, %A_LoopFileFullPath%
		if(_oldestTimeStamp = 0 || _oldestTimeStamp > lastModifiedTimestamp) {
			_oldestTimeStamp := lastModifiedTimestamp 
			_oldestFile		 :=  A_LoopFileFullPath
		}
	}	
}

;we need the parent folder's name, this is the name we have to search for in the .inis
StringSplit, word_array, _oldestFile, \\, .  ; Omits periods.

length 				:= word_array0
targetLength 		:= length -1

targetFolderName	:= word_array%targetLength%
;M sgBox, folder name %targetFolderName%

Loop, %backupInisBaseDir%\*.ini,  , 1  ; Recurse into subfolders.
{
	IniRead, folder, %A_LoopFileFullPath%, general, folder
	if(folder = targetFolderName) {
		;M sgBox, %A_LoopFileFullPath%
		target = "%A_ScriptDir%\ftpBackup.ahk" %A_LoopFileName%
		;M sgBox, %target%
		Run, %target%
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