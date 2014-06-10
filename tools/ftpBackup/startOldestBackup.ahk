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

; get settings file name for the oldest backup
backup := 	getOldestBackup(backupBaseDir, getValidDirectories(backupInisBaseDir))

target = "%A_ScriptDir%\ftpBackup.exe" %backup%
; M sgBox, %target%
Run, %target%
ExitApp
return

/**
 *	Get array key for value
 *
 *	@param 	array		arr			Array to search for the value
 *	@param 	string		e			Value to search for
 *	
 *	@return string	If exists, the array key for the value, false otherwise
 */
getKeyForValue(arr, e) {
	For k, v in arr {	
		if(v == e) {
			return k			
		}
	}
	return false	
}

/**
 *	Get all active backup directories from settings files (*.ftpbackup) in a directory
 *
 *	@param	string		dir			Directory with settings files (*.ftbackup)
 *
 *	@return array		Contains all backup folders from the settings files
 *						e.g. array('test_de.ftbackup' => 'test_de', ..)
 */
getValidDirectories(dir) {
	folders := []
	Loop, % dir . "\*.ftpbackup", , 1 
	{
		IniRead, folder, %A_LoopFileFullPath%, general, folder	
		folders[A_LoopFileName] := folder	
	} 
	return folders
}

/**
 *	Get settings file name for the oldest backup.
 *	Checks also if the directory is one of the active backups
 *
 *	@param	string		dir			Directory with backups
 *	@param	array		folders		Contains valid directories and correct settings file name
 *
 *	@return string		Settings file name. e.g. 'test_de.ftbackup'.
 */
getOldestBackup(dir, folders) {
	oldestFile 		:= 0,
	oldestTimeStamp := 0
	
	Loop, % dir "\*.*", 2, 0
	{
		currentDir := A_LoopFileFullPath . "\current"
		if(FileExist(currentDir)) {		
			FileGetTime, lastModifiedTimestamp, % currentDir
			
			ini := getKeyForValue(folders, A_LoopFileName)			
			if(ini && (oldestTimeStamp == 0 || oldestTimeStamp > lastModifiedTimestamp)) {
				oldestTimeStamp	:= lastModifiedTimestamp,
				oldestFile		:= ini			
			}			
		}
	}
	return oldestFile
}

Reload:
	Reload
return 

Exit:
	ExitApp
return