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

SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2


Menu, tray, NoStandard
Menu, tray, add  ; Creates a separator line.
Menu, tray, add, Reload  
Menu, tray, add, Exit

FormatTime, year, , yyyy
FormatTime, month, , MM
FormatTime, day, , dd
;MsgBox The current time and date (time first) is %TimeString%.
newFolder = e:\[--Working Old--]\backup_%year%_%month%_%day%

FileCreateDir, %newFolder%

MoveFilesAndFolders("E:\[--Working--]\*.*", newFolder, false)

ExitApp

Reload:
	Reload
return 

Exit:
	ExitApp
return

if(!A_IsCompiled) {
	#y::
		;ControlGetText, output , SysListView321, 
		;ControlGet, output, Line, 1, SysListView321, - Notepad++
		Send ^s
		reload
	return
}

MoveFilesAndFolders(SourcePattern, DestinationFolder, DoOverwrite = false)
; Moves all files and folders matching SourcePattern into the folder named DestinationFolder and
; returns the number of files/folders that could not be moved. This function requires v1.0.38+
; because it uses FileMoveDir's mode 2.
{
    if DoOverwrite = 1
        DoOverwrite = 2  ; See FileMoveDir for description of mode 2 vs. 1.
    ; First move all the files (but not the folders):
    FileMove, %SourcePattern%, %DestinationFolder%, %DoOverwrite%
    ErrorCount := ErrorLevel
    ; Now move all the folders:
    Loop, %SourcePattern%, 2  ; 2 means "retrieve folders only".
    {
		;M sgBox, %A_LoopFileName%
		Needle = [--
		IfInString, A_LoopFileName, %Needle%
		{
			;M sgBox, The string was found %A_LoopFileName%
			continue
		}
		Needle2 = __
		IfInString, A_LoopFileName, %Needle2%
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