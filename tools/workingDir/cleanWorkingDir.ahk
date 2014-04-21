#NoEnv
#NoTrayIcon
SendMode Input 
#SingleInstance force
#Persistent

SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2

Menu, tray, NoStandard
Menu, tray, add, Reload  
Menu, tray, add, Exit

SplashTextOn, , , Cleaning working directory...
Sleep, 1000

INI_FILE := iniFile()
IniRead, workingDir, %INI_FILE%, settings, workingDir
StringLen, cLength, workingDir

if(cLength = 0 || workingDir = "ERROR") {
	MsgBox, please set workingDir in %INI_FILE%
	ExitApp
}

IniRead, workingBackupDir, %INI_FILE%, settings, workingBackupDir
StringLen, cLength, workingBackupDir

if(cLength = 0 || workingBackupDir = "ERROR") {
	MsgBox, please set workingBackupDir in %INI_FILE%
	ExitApp
}

IniRead, needleNotToMove, %INI_FILE%, settings, dontMoveFoldersWithPrefix1
if(needleNotToMove = "ERROR") {
	needleNotToMove = ""
}
IniRead, needle2NotToMove, %INI_FILE%, settings, dontMoveFoldersWithPrefix2
if(needle2NotToMove = "ERROR") {
	needle2NotToMove = ""
}

FormatTime, year, , yyyy
FormatTime, month, , MM
FormatTime, day, , dd
;M sgBox The current time and date (time first) is %TimeString%.
newFolder = %workingBackupDir%\backup_%year%_%month%_%day%

;M sgBox, %newFolder%
FileCreateDir, %newFolder%

sourcePattern = %workingDir%\*.*

MoveFilesAndFolders(sourcePattern, newFolder, false, needleNotToMove, needle2NotToMove)

SplashTextOn, , , done...
Sleep, 1000

ExitApp

Reload:
	Reload
return 

Exit:
	ExitApp
return

; Moves all files and folders matching SourcePattern into the folder named DestinationFolder and
; returns the number of files/folders that could not be moved. This function requires v1.0.38+
; because it uses FileMoveDir's mode 2.
MoveFilesAndFolders(SourcePattern, DestinationFolder, DoOverwrite = false, needleNotToMove = "", needle2NotToMove = "") {
	;M sgBox, %SourcePattern%
    if DoOverwrite = 1
        DoOverwrite = 2  ; See FileMoveDir for description of mode 2 vs. 1.
    ; First move all the files (but not the folders):
    FileMove, %SourcePattern%, %DestinationFolder%, %DoOverwrite%
    ErrorCount := ErrorLevel
    ; Now move all the folders:
    Loop, %SourcePattern%, 2  ; 2 means "retrieve folders only".
    {
		;M sgBox, %A_LoopFileName%
		IfInString, A_LoopFileName, %needleNotToMove%
		{
			;M sgBox, The string was found %A_LoopFileName%
			continue
		}

		IfInString, A_LoopFileName, %needle2NotToMove%
		{
			continue
		}
        FileMoveDir, %A_LoopFileFullPath%, %DestinationFolder%\%A_LoopFileName%, %DoOverwrite%
        ErrorCount += ErrorLevel
        if ErrorLevel  ; Report each problem folder by name.
            MsgBox Could not move %A_LoopFileFullPath% into %DestinationFolder%.
    }
    return ErrorCount
}

; loading correct ini
; you can either use %INI_FILE% or COMPUTERNAME_%INI_FILE%
iniFile() {
	iniFile			:= ScriptNameNoExt() . ".ini"
	iniFileLocal 	:= A_ComputerName . "_" . iniFile
	if(FileExist(iniFileLocal)) {
		iniFile := iniFileLocal
	}
	return iniFile
}

ScriptNameNoExt() {
    SplitPath, A_ScriptName,,,, ScriptNameNoExt
    return ScriptNameNoExt
}
