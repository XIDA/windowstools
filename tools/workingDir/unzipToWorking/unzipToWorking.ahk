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

CoordMode, Mouse, Screen
SetTitleMatchMode, 2
Menu, tray, NoStandard

;path := "E:\[--Current Projects--]\[--Sugarsync--]\[--20120905 - GB - ASA App Update--]\[--Source--]\20120921_email\Sammlung_Korrekturen_ASA_Tablet.zip"
;path := "E:\[--Current Projects--]\[--Sugarsync--]\[--20120905 - GB - ASA App Update--]\[--Source--]\20120906_download\CFS_120726_ASA_EN_Tabletversion_Nachbearbeitung_gekuerzt_jk.doc"
path = %1%

;M sgBox, %path%

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
	
	FileCreateDir, e:\[--Working--]\%cDir%\*.*
	;copy a directory
	FileCopy, %A_WorkingDir%\*.*, e:\[--Working--]\%cDir%\*.*, 1
	newPath = e:\[--Working--]\%cDir%
	;ExitApp
} else 
{

	SetWorkingDir %A_ScriptDir%

	SplitPath, path, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive


	cExt := OutExtension

	If (InStr("zip", cExt) || InStr("rar", cExt))
	{
		
		;M sgBox, 7z.exe x "%1%" -o"e:\[--Working--]" -aoa

		RunWait, 7z.exe e "%1%" -o"e:\[--Working--]\%OutNameNoExt%" -aoa

		;Run explore e:\[--Working--]\%OutNameNoExt%

		newPath = e:\[--Working--]\%OutNameNoExt%
		;newPath = e:\[--Working--]\
	} else {
		FileCopy, %path%, e:\[--Working--]\, 1
		newPath = e:\[--Working--]\
	}

}

Sleep, 500

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
