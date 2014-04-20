#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.

#SingleInstance force
#Persistent 
#NoTrayIcon
SetBatchLines -1
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
SetTitleMatchMode 2


ControlGetPos,,,w,h,ToolbarWindow321, AHK_class Shell_TrayWnd
width:=w, hight:=h
While % ((h:=h-5)>0 and w:=width){
	While % ((w:=w-5)>0){
		PostMessage, 0x200,0,% ((hight-h) >> 16)+width-w,ToolbarWindow321, AHK_class Shell_TrayWnd
	}
}

ExitApp
return


