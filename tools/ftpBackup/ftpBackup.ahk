#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
#SingleInstance force
#Persistent ;Script nicht beenden nach der Auto-Execution-Section

SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2

#include ..\_libs\helperFunctions.ahk
#include ..\_libs\tf.ahk

Menu, tray, NoStandard
Menu, tray, Icon, ftpBackup.ico,  1
Menu, Tray, Click, 1
Menu, Tray, add, &Status, status
Menu, Tray, Default, &Status
Menu, tray, add  ; Creates a separator line.
Menu, tray, add, Reload  
Menu, tray, add, Exit

7ZIP_PATH 					= ..\_libs\bin\7z.exe
WGET_FILE 			 		= bin\wget.exe
LISTING_FILE		 		= .listing
LOG_FILE_PREFIX 		 	= backup
CLEAN_LOG_FILE_PREFIX		= cleanup
INI_FILE 					:= iniFile()
_lastStatusText		 		= 
_filesDeleted				= false

_wgetProcessID				=
_7zipProcessID				=
	
IniRead, backupBaseDir, %INI_FILE%, general, backupBaseDir, backup
IniRead, backupInisBaseDir, %INI_FILE%, general, backupBaseDir, ""
IniRead, wgetParameters, %INI_FILE%, wget, parameters

if 0 < 1
{
	;MsgBox, set the name of the settings ini as first parameter
	;ExitApp
	SETTINGS_INI_FILE	= %backupInisBaseDir%\ftp_xida_de.ini
	
} else {
	SETTINGS_INI_FILE	= %backupInisBaseDir%\%1%
}


;M sgBox, %SETTINGS_INI_FILE%

IniRead, folder, %SETTINGS_INI_FILE%, general, folder
IniRead, ftpHost, %SETTINGS_INI_FILE%, general, host
IniRead, ftpUser, %SETTINGS_INI_FILE%, general, user
IniRead, ftpPass, %SETTINGS_INI_FILE%, general, pass

_guiVisible 	= false
_backupDir		= %backupBaseDir%\%folder%\current
_backupLogFile 	= %_backupDir%\%LOG_FILE_PREFIX%.log
_cleanupLogFile = %_backupDir%\%CLEAN_LOG_FILE_PREFIX%.log
_statusFile		= %_backupDir%\status.log

Gui, Add, ListView, w580 r15 vLogDisplay, Created|Status
Gui +Resize
Gui, Show, w600 h300, ftpBackup - %folder%

status("starting...")

FileCreateDir, %_backupDir%
Run, %WGET_FILE% %wgetParameters% -nv -o %_statusFile% --ftp-user=%ftpUser% --ftp-password=%ftpPass% --directory-prefix=%_backupDir% ftp://%ftpHost%,, Hide, _wgetProcessID


Sleep, 3000

SetTimer, checkStatus , 1000
	
return

checkStatus:
	cText := TF_Tail(_statusFile, 2,1,1) 
		
	;check if finished
	if(isFinished(cText)) {
		SetTimer, checkStatus, OFF
		checkForFilesThatShouldBeDeleted(_backupDir, LISTING_FILE, _cleanupLogFile)
		generateReport(_statusFile, _backupLogFile)
		
		status("archiving...")
		FormatTime, TimeString, , yyyyddMM_HHmmss		
		archivePath 	=  %backupBaseDir%\%folder%\%TimeString%_%folder%.7z
		archiveBackup(_backupDir, archivePath, 7ZIP_PATH)
		
		
		status("done")
		Sleep, 3000		
		ExitApp

	}
	
	if(!ProcessExist(_wgetProcessID)) {
		MsgBox, wtf
		FileAppend, ERROR wget process crashed`n, %_backupLogFile%
		ExitApp
	}
	

	
	;display status
	if(_lastStatusText != cText) {
		_lastStatusText := cText
		formattedText	:= formatLogLine(_lastStatusText)
		status(formattedText)
	}

	
return

status:
	_guiVisible := !_guiVisible
	
	if(_guiVisible) {
		Gui, Show
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

ProcessExist(PidOrName) {

	Process, Exist, %PidOrName%

	return ErrorLevel

}

archiveBackup(backupDir, destPath, 7zippath) {
	;MsgBox, %backupDir%
	global _7zipProcessID
	RunWait, %7zippath% a -t7z "%destPath%" %backupDir%\*,, Hide, _7zipProcessID
}

checkForFilesThatShouldBeDeleted(directory, listingFileName, cleanupLogFile) {
	FileDelete, %cleanupLogFile%
	
	cleanupDeletedFiles(directory, listingFileName, cleanupLogFile)
	
	if(!_filesDeleted) {
		FileAppend, No files were deleted`n, %cleanupLogFile%
	}
}

cleanupDeletedFiles(directory, listingFileName, cleanupLogFile) {
	global _filesDeleted
	
	Loop, %directory%\%listingFileName%, 0, 0
	{
		;M sgBox, listingfile = %A_LoopFileFullPath%
		cFilesDeleted := cleanupDeletedFilesForDirectory(A_LoopFileDir, listingFileName, A_LoopFileFullPath, cleanupLogFile)
		if(cFilesDeleted) {
			_filesDeleted = true
		}
		
	}	
	
	Loop, %directory%\*, 2, 0
	{
		;M sgBox, subdir = %A_LoopFileFullPath%
		cleanupDeletedFiles(A_LoopFileFullPath, listingFileName, cleanupLogFile)
		;cleanupDeletedFilesForDirectory(A_LoopFileDir, listingFileName, A_LoopFileFullPath)
		
	}	
}

cleanupDeletedFilesForDirectory(directory, listingFileName, listingFile, cleanupLogFile) {
	cFileContent := TF_ReadLines(listingFile)
	;M sgBox, %cFileContent%
	
	filesDeleted = false
	Loop, %directory%\*, 1, 0 
	{	
		;M sgBox, A_LoopFileName %A_LoopFileName%
		if(A_LoopFileName != listingFileName) {		
			containsFile := TF_Count(cFileContent, A_LoopFileName)
			if(containsFile = 0) {
				;M sgBox, Delete file! %A_LoopFileFullPath%
				If InStr( FileExist( A_LoopFileFullPath  ), "D" )
				{
					;M sgBox Directory!
					FileRemoveDir, %A_LoopFileFullPath%, 1
					FileAppend, Deleted directory %A_LoopFileFullPath%`n, %cleanupLogFile%					
				} else
				{
					;M sgBox FILE			
					FileDelete, %A_LoopFileFullPath%
					FileAppend, Deleted file %A_LoopFileFullPath%`n, %cleanupLogFile%
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
	if(containsSubstring(cText, "Downloaded:")) {
		return true
	} 
	
	return false
}
formatLogLine(cText, reportListing = true, reportFullFilePath = false) {
	global _statusFile
	global folder
	global ftpHost
	
	if(containsSubstring(cText, "FINISHED")) {		
		return "FINISHED"
	}
	
	if(containsSubstring(cText, "Downloaded:")) {
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
	
	FoundPos := RegExMatch(cText, """(.*)\/(.*)\"" \[", outputvar) 	
	;M sgBox, %outputvar1% %outputvar2%	
	returnText = 
	if(outputvar2 = .listing) {
		if(reportListing) {
			filePath = %outputvar1%
			StringReplace, filePath, filePath, %folder%\%ftpHost% , 			
			returnText = listing directory %filePath%
		}
	} else {
		if(reportFullFilePath) {
			filePath = %outputvar1%\%outputvar2%
			StringReplace, filePath, filePath, %folder%\%ftpHost% , 			
			returnText = downloading file  %filePath%
			
		} else {
			returnText = downloading file %outputvar2%
		}
	}
	
	return returnText
}

containsSubstring(cText, prefix) {
	IfInString, cText, %prefix%
	{
		return true
	}
	
	return false

}