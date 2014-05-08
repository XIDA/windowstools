#SingleInstance, Force
#NoEnv
#Persistent
SetWorkingDir %A_ScriptDir%

Menu, tray, NoStandard
Menu, tray, Icon, macKeyboardShortcuts.ico,  1
Menu, tray, add, Reload  
Menu, tray, add, Exit

#include %A_ScriptDir%\..\_libs\helperFunctions.ahk

#a::^a
#z::^z
#c::^c
#v::^v
#s::^s
#f::^f
#x::^x


Reload:
	Reload
return 

Exit:
	ExitApp
return
