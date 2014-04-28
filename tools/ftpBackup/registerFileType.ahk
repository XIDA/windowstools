#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
#SingleInstance force
#Persistent ;Script nicht beenden nach der Auto-Execution-Section

SetWorkingDir %A_ScriptDir%


_addRegFilename 			= registerFileExtension.reg


FileDelete, %_addRegFilename% 

;create reg file
FileRead, cContents, templates\%_addRegFilename%
cDir = %A_ScriptDir%
StringReplace, cDir, cDir, \ , \\, All
StringReplace, cContents, cContents, {currentfolder} , %cDir%, All
FileAppend, %cContents%, %_addRegFilename%
;M sgBox, %cContents%
RunWait, %_addRegFilename%
FileDelete, %_addRegFilename%
ExitApp


