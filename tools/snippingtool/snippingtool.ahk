;starts the snipping tool and immediately starts the screenshot process

#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
#SingleInstance force
#Persistent ;Script nicht beenden nach der Auto-Execution-Section
#NoTrayIcon
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2

WinClose, Snipping Tool
Run, c:\windows\system32\SnippingTool.exe
WinWait, Snipping Tool
WinActivate, Snipping Tool
Send, ^n
ExitApp



