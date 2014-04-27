#NoEnv
#NoTrayIcon
SendMode Input
#SingleInstance force
#Persistent

SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2

#include ..\..\_libs\helperFunctions.ahk

Menu, tray, NoStandard

INI_FILE := helperIniFile()
;M sgBox, %INI_FILE%

addRegFilename 		= AddToRightClickMenu.reg
removeRegFilename 	= RemoveFromRightClickMenu.reg


IniRead, openToExtractedFolder, %INI_FILE%, settings, openToExtractedFolder,0
IniRead, _7zipPath, %INI_FILE%, settings, 7zipDir,

IniRead, workingDir, %INI_FILE%, settings, workingDir
StringLen, cLength, workingDir

if(cLength = 0 || workingDir = "ERROR") {
	MsgBox, please set workingDir in %INI_FILE%
	ExitApp
}


path = %1%
StringLen, cLength, path
if(cLength > 0) {
	GoSub, handlePath
	return
}


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

return

handlePath:
	;if true
	if path is alpha
	{
		SplitPath, A_WorkingDir, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
		;MsgBox, %OutDir%
		StringSplit, word_array, A_WorkingDir, \, .  ; Omits periods.
		cLength = %word_array0%
		
		cDir := word_array%cLength%
		;MsgBox,  %cLength% %cDir% - %word_array0% The 4th word is %word_array5%.	
		;MsgBox, e:\[--Working--]\%cDir%\*.*,
		
		FileCreateDir, %workingDir%\%cDir%\*.*
		;copy a directory
		FileCopy, %A_WorkingDir%\*.*, %workingDir%\%cDir%\*.*, 1
		newPath = %workingDir%\%cDir%
		;ExitApp
	} else 
	{
		SplitPath, path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive


		cExt := OutExtension

		If (InStr("zip", cExt) || InStr("rar", cExt) || || InStr("7z", cExt))
		{
			
			;M sgBox, 7z.exe x "%1%" -o"e:\[--Working--]" -aoa

			RunWait, %_7zipPath% e "%1%" -o"%workingDir%\%OutNameNoExt%" -aoa,,hide

			;Run explore e:\[--Working--]\%OutNameNoExt%

			newPath = %workingDir%\%OutNameNoExt%
			;newPath = e:\[--Working--]\
		} else {
			FileCopy, %path%, %workingDir%\, 1
			newPath = %workingDir%\
		}

	}

	Sleep, 500

	if(openToExtractedFolder = 0) {
		ExitApp
	}

	h :=   WinExist("A")
	For win in ComObjCreate("Shell.Application").Windows
	   if   (win.hwnd=h)
			 win.Navigate[newPath]
	Until   (win.hwnd=h)


	Sleep, 500

	h :=   WinExist("A")
	For win in ComObjCreate("Shell.Application").Windows
	   if   (win.hwnd=h)
			 win.Navigate[newPath]
	Until   (win.hwnd=h)

	ExitApp
return
