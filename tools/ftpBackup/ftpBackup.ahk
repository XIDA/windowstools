#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
#SingleInstance off
#Persistent ;Script nicht beenden nach der Auto-Execution-Section

SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2

#include %A_ScriptDir%\..\_libs\helperFunctions.ahk
#include %A_ScriptDir%\..\_libs\tf.ahk
#include %A_ScriptDir%\..\_libs\Array.ahk

Menu, tray, NoStandard
Menu, tray, Icon, ftpBackup.ico,  1
Menu, Tray, Click, 1
Menu, Tray, add, &Status, status
Menu, Tray, Default, &Status
Menu, tray, add  ; Creates a separator line.
Menu, tray, add, Reload  
Menu, tray, add, Exit

WGET_FILE 			 		= bin\wget.exe
LISTING_FILE		 		= .listing
LOG_FILE_PREFIX 		 	= backup
CLEAN_LOG_FILE_PREFIX		= cleanup

_iniFile 					:= helperIniFile()
_lastStatusText		 		= 

_wgetProcessID				=
_7zipProcessID			    =

;load settings from main ini START
;directories
IniRead, backupBaseDir, 					%_iniFile%, directories, backupBaseDir, backup
IniRead, backupInisBaseDir, 				%_iniFile%, directories, backupInisBaseDir, ""
IniRead, 7zipPath,							%_iniFile%, directories, 7zipDir,
	
IniRead, numberOfArchivesToKeep,			%_iniFile%, settings, numberOfArchivesPerBackupToKeep, 5

;execute before backup
IniRead, exectuteBeforeBackup,				%_iniFile%, beforebackup, execute, 0

;execute after backup
IniRead, exectuteAfterBackup,				%_iniFile%, afterbackup, execute, 0

;wget settings
IniRead, wgetParameters, 	%_iniFile%, wget, parameters

;load settings from main ini END

_addRegFilename 			= registerFileExtension.reg

IfNotExist, %_addRegFilename% 
{
	;create reg file
	FileRead, cContents, regTemplates\%_addRegFilename%
	cDir = %A_ScriptDir%
	StringReplace, cDir, cDir, \ , \\, All
	StringReplace, cContents, cContents, {currentfolder} , %cDir%, All
	FileAppend, %cContents%, %_addRegFilename%
	;M sgBox, %cContents%
	RunWait, %_addRegFilename%
	;FileDelete, %_addRegFilename%
	ExitApp
}
;M sgBox, %1%

;check if there is a command line parameter
if 0 < 1
{
	if(!A_IsCompiled) {
		_settingsIniFile	= %backupInisBaseDir%\ftp_xida_de.ini
	} else {
		MsgBox, set the name of the settings ini as first parameter
		ExitApp	
	}
	
} else {
	;check if its a full path	
	cPath = %1%
	if InStr(cPath, ":")
	{
		_settingsIniFile		= %cPath%
	} else 
	{
		_settingsIniFile		= %backupInisBaseDir%\%cPath%
	}
	
}


;M sgBox, %_settingsIniFile%

;load current backup project settings
IniRead, folder, 			%_settingsIniFile%, general, folder
IniRead, ftpHost, 			%_settingsIniFile%, general, host
IniRead, ftpUser,			%_settingsIniFile%, general, user
IniRead, ftpPass, 			%_settingsIniFile%, general, pass

IniRead, beforebackupAdd, 	%_settingsIniFile%, beforebackup, add, ""
IniRead, afterbackupAdd, 	%_settingsIniFile%, afterbackup, add, ""

_guiVisible 				= false
_backupDir					= %backupBaseDir%\%folder%\current
_backupLogFile 				= %_backupDir%\%LOG_FILE_PREFIX%.log
_cleanupLogFile 			= %_backupDir%\%CLEAN_LOG_FILE_PREFIX%.log
_statusFile					= %_backupDir%\status.log
_statusFileCurrentLine 		:= 0
_statusFileCheckInProgress 	:= false


if(Strlen(exectuteBeforeBackup) > 1) {
	RunWait, %exectuteBeforeBackup%%beforebackupAdd%
}
	
;setupgui
Gui, Add, ListView, w580 r15 vLogDisplay, Created|Status
Gui +Resize
;Gui, Show, w600 h300, ftpBackup - %folder%

FormatTime, timeString, ,dd-MM-yyyy HH:mm:ss	
tipText = Backup - %folder% - started %timeString%
Menu, Tray, Tip, %tipText%
status("starting...")

FileCreateDir, %_backupDir%
FileDelete, %_statusFile% 
Run, %WGET_FILE% %wgetParameters% -nv -o %_statusFile% --ftp-user=%ftpUser% --ftp-password=%ftpPass% --directory-prefix=%_backupDir% ftp://%ftpHost%,, HIDE, _wgetProcessID


SetTimer, checkStatus, 1000
SetTimer, checkIfProcessIsRunning, 10000
	
return

checkIfProcessIsRunning:
	if(_statusFileCheckInProgress) 
	{
		return
	}
	
	if(!helperProcessExist(_wgetProcessID)) {
		FileAppend, ERROR wget process crashed`n, %_backupLogFile%
		ExitApp
	}
return

checkStatus:
	if(_statusFileCheckInProgress) 
	{
		return
	}
	
	_statusFileCheckInProgress := true


	TF(_statusFile)	
	numLines := TF_CountLines(t)

	
	Loop, %numLines%
	{
		i := A_INDEX
		
		if(i < _statusFileCurrentLine) 
		{
			continue
		}
		
		_currentText := TF_ReadLines(t,i, i) 
		GoSub, checkStatusFromText
	}		
	
	_statusFileCurrentLine := numLines
	
	_statusFileCheckInProgress := false
	
return

checkStatusFromText:
	
	;check if finished
	if(isFinished(_currentText)) {
		SetTimer, checkStatus, OFF
		checkForFilesThatShouldBeDeleted(_backupDir, LISTING_FILE, _cleanupLogFile)
		generateReport(_statusFile, _backupLogFile)
		
		status("archiving...")
		FormatTime, TimeString, , yyyyddMM_HHmmss		
		archivePath 		=  %backupBaseDir%\%folder%
		archivePathAndName 	=  %archivePath%\%TimeString%_%folder%.7z
		archiveBackup(_backupDir, archivePath, 7zipPath)		
		
		status("checking old backups...")
		filesDeleted := checkOldBackups(numberOfArchivesToKeep, archivePath)
		if(filesDeleted) {
			status("old backups deleted")
		}
		status("done")		
		
		if(Strlen(exectuteAfterBackup) > 1) {
			RunWait, %exectuteAfterBackup%%afterbackupAdd%
		}
			
		Sleep, 3000		
		ExitApp

	}

	;display status
	if(_lastStatusText != _currentText) {
		_lastStatusText := _currentText
		length := Strlen(_currentText)
		if(length > 1) {
			formattedText	:= formatLogLine(_currentText)
			status(formattedText)
		}
	}	
return

status:
	_guiVisible := !_guiVisible
	
	if(_guiVisible) {
		Gui, Show, w600 h300, ftpBackup - %folder%
	} else {
		Gui, Hide
	}
return

GuiSize:
	GuiControl, Move, LogDisplay, % "W" . (A_GuiWidth - 20) . " H" . (A_GuiHeight - 40)
Return

Reload:
	Process, Close, %_wgetProcessID%
	Process, Close, %_7zipProcessID%
	
	Reload
return 

Exit:
	Process, Close, %_wgetProcessID%
	Process, Close, %_7zipProcessID%
	
	ExitApp
return

status(message) {
	;global folder	
	;T rayTip, Backup - %folder%, %message%
	
	FormatTime, timeString, , yyyy-dd-MM HH:mm:ss	
	rowNumber := LV_Add("", timeString, message)
	LV_Modify(rowNumber, "Vis")
	LV_ModifyCol()
}

archiveBackup(backupDir, destPath, 7zippath) {
	;MsgBox, %backupDir%
	global _7zipProcessID
	RunWait, %7zippath% a -t7z "%destPath%" %backupDir%\*,, Hide, _7zipProcessID
}

checkOldBackups(numberOfArchivesPerBackupToKeep, archivePath) {
	
	filesDeleted := false
	
	files := Array()
	Loop, %archivePath%\*.7z, 0 , 0
	{
		files.append(A_LoopFileFullPath)   ; Store this line in the next array element.
	}	
	
	files := files.reverse()
	
	;M sgbox, % files.join("`n")
	
	Loop, % files.len()
	{
		if(A_Index > numberOfArchivesPerBackupToKeep) {			
			cFile := files[A_Index] 
			;M sgbox, %cFile%
			FileDelete, %cFile%
			filesDeleted := true
		}
	}
	return filesDeleted
}


checkForFilesThatShouldBeDeleted(directory, listingFileName, cleanupLogFile) {
	FileDelete, %cleanupLogFile%
	
	cleanupDeletedFiles(directory, listingFileName, cleanupLogFile)
	
	if(!FileExist(cleanupLogFile)) {
		FileAppend, No files were deleted`n, %cleanupLogFile%
	}
}

cleanupDeletedFiles(directory, listingFileName, cleanupLogFile) {
	
	Loop, %directory%\%listingFileName%, 0, 0
	{
		;M sgBox, listingfile = %A_LoopFileFullPath%
		cleanupDeletedFilesForDirectory(A_LoopFileDir, listingFileName, A_LoopFileFullPath, cleanupLogFile)
		
	}	
	
	Loop, %directory%\*, 2, 0
	{
		;M sgBox, subdir = %A_LoopFileFullPath%
		cleanupDeletedFiles(A_LoopFileFullPath, listingFileName, cleanupLogFile)
		;cleanupDeletedFilesForDirectory(A_LoopFileDir, listingFileName, A_LoopFileFullPath)
		
	}	
}

cleanupDeletedFilesForDirectory(directory, listingFileName, listingFile, cleanupLogFile) {
	global _backupDir
	global ftpHost
	
	empty := " "
	cFileContent := TF_ReadLines(listingFile)
	;M sgBox, %cFileContent%
	
	filesDeleted = false
	Loop, %directory%\*, 1, 0 
	{	
		;M sgBox, A_LoopFileName %A_LoopFileName%
		if(A_LoopFileName != listingFileName) {		
		
			;there is always a space before, and a line break after the name
			searchFor := empty . A_LoopFileName . "`n"		
			;M sgBox, %searchFor%
			containsFile := TF_Count(cFileContent, searchFor)
			if(containsFile = 0) {
				;M sgBox, Delete file! %A_LoopFileFullPath%
				If InStr( FileExist( A_LoopFileFullPath  ), "D" )
				{
					;M sgBox Directory!
					FileRemoveDir, %A_LoopFileFullPath%, 1
					StringReplace, filePath, A_LoopFileFullPath, %_backupDir%\%ftpHost%
					FileAppend, Deleted directory %filePath%`n, %cleanupLogFile%					
				} else
				{
					;M sgBox FILE			
					FileDelete, %A_LoopFileFullPath%
					StringReplace, filePath, A_LoopFileFullPath, %_backupDir%\%ftpHost%
					FileAppend, Deleted file %filePath%`n, %cleanupLogFile%
				}
				
				filesDeleted = true
			}
			;MsgBox, contains? = %A_LoopFileFullPath%`n`n%containsFile%
			;cleanupDeletedFilesForDirectory(A_LoopFileDir, listingFileName, A_LoopFileFullPath)			
		}		
	}	
	
	return filesDeleted
}

generateReport(status_file, logfile) {
	FileDelete, %logfile%
	;M sgBox, %logfile%
	
	Loop
	{
		FileReadLine, line, %status_file%, %A_Index%
		if ErrorLevel
			break
			
		;MsgBox, Line #%A_Index% is "%line%".  Continue?
		cText := formatLogLine(line, false, true)
		if(Strlen(cText) > 0) {
			FileAppend, %cText%`n, %logfile%
		}
		
	}	
}

isFinished(cText) {
	if(helperContainsSubstring(cText, "Downloaded:")) {
		return true
	} 
	
	return false
}

formatLogLine(cText, reportListing = true, reportFullFilePath = false) {
	global _statusFile
	global folder
	global _backupDir
	global ftpHost
	
	if(Strlen(cText) = 0) {
		return NULL
	}
	
	if(helperContainsSubstring(cText, "FINISHED")) {		
		return "FINISHED"
	}
	
	if(helperContainsSubstring(cText, "Connection timed out")) {		
		return "Connection timed out"
	}
	
	
	if(helperContainsSubstring(cText, "Downloaded:")) {
		FoundPos := RegExMatch(cText, "Downloaded: ([0-9]*)", outputvar) 	
		downloadedFilesAmount = %outputvar1%
		;M sgBox, %downloadedFilesAmount%
		;ok, we need to substract the .listing files
		cFileContent := TF_ReadLines(_statusFile)
		listingAmount := TF_Count(cFileContent, ".listing")
		;M sgBox, %listingAmount%
		
		realDownloadedFilesAmount := downloadedFilesAmount - listingAmount
		
		returnText = downloaded files: %realDownloadedFilesAmount%
		return returnText
	}	
	
	if(helperContainsSubstring(cText, "No such file")) {
		FoundPos := RegExMatch(cText, "No such file (.*)", outputvar) 	
		returnText = No such file %outputvar1%
		return returnText
	}
	
	FoundPos := RegExMatch(cText, """(.*)\/(.*)\"" \[", outputvar) 	
	;M sgBox, %outputvar1% %outputvar2%	
	returnText = 
	
	StringReplace, backupDirReversed, _backupDir, \, /, 1
	if(outputvar2 = .listing) {	
		if(reportListing) {
			filePath = %outputvar1%
			StringReplace, filePath, filePath, %backupDirReversed%/%ftpHost%  			
			returnText = listing directory %filePath%
		}
	} else {
		if(reportFullFilePath) {
			;M sgBox, %cText%
			filePath = %outputvar1%/%outputvar2%
			StringReplace, filePath, filePath, %backupDirReversed%/%ftpHost% , 			
			returnText = downloading file  %filePath%
			
		} else {
			returnText = downloading file %outputvar2%
		}
	}
	
	return returnText
}
