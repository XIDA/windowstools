#NoEnv 
SendMode Input
#SingleInstance force
#Persistent
#NoTrayIcon
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2

Gui, Show,,Fixing...
RunWait, %comspec% /c ipconfig /release,,hide
RunWait, %comspec% /c ipconfig /flushdns,,hide
RunWait, %comspec% /c ipconfig /renew,,hide
ExitApp



