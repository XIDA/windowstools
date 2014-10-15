#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
#SingleInstance force
#Persistent ;Script nicht beenden nach der Auto-Execution-Section
SetTitleMatchMode, 3		; 2: A window's title can contain WinTitle anywhere inside it to be a match. 
SetTitleMatchMode, Slow		;Fast is default
DetectHiddenWindows, off	;Off is default
SetWorkingDir %A_ScriptDir%  ; Ensures a consistent starting directory.

#include %A_ScriptDir%\..\_libs\helperFunctions.ahk

CRLF = `r`n
FILE_NAME = %A_TEMP%\WinPos.txt

TRAY_TITLE = Displayport Helper

_winPosSavedSinceLastIdle := 0

Menu, tray, NoStandard
Menu, tray, add, Save positions, saveWinPos
Menu, tray, add, Restore positions, restoreWinPos
Menu, tray, add  ; Creates a separator line.

if(hasAutostartShortCut()) {
	Menu, tray, add, Remove from autostart, removeFromAutostart
} else {
	Menu, tray, add, Add to autostart, addToAutostart
}
Menu, tray, add  ; Creates a separator line.
Menu, tray, add, Reload  
Menu, tray, add, Exit
Menu, Tray, Icon, displayportHelper.ico

INI_FILE := helperIniFile()
IniRead, iniIdleLimit, %INI_FILE%, general, idlelimit
IniRead, iniCheckInterval, %INI_FILE%, general, checkInterval
IniRead, iniCheckIntervalIdle, %INI_FILE%, general, checkIntervalIdle
IniRead, iniMonitorsAmount, %INI_FILE%, general, monitorsAmount
IniRead, iniPauseBeforeRestore, %INI_FILE%, general, pauseBeforeRestore
IniRead, iniShowTrayTips, %INI_FILE%, general, showTrayTips
IniRead, iniExecuteBeforeRestore, %INI_FILE%, general, executeBeforeRestore
IniRead, iniExecuteAfterRestore, %INI_FILE%, general, executeAfterRestore

SetTimer, check, %iniCheckInterval%

return


/*
F1::
	GoSub, saveWinPos
return

F2::
	GoSub, restoreWinPos
return
*/

check:
	SetTimer, check, off

	GoSub, checkMonitorCount	

	if(checkIdle()) {
		if(_winPosSavedSinceLastIdle = 0) {
			_winPosSavedSinceLastIdle := 1
			GoSub, saveWinPos
		}
		; if idle, we need to check more often or we will miss when the displayport device is switched on again
		SetTimer, check, %iniCheckIntervalIdle%
		
	} else {			
		_winPosSavedSinceLastIdle := 0
		SetTimer, check, %iniCheckInterval%	
	}
return

showTrayTip(text) {
	global iniShowTrayTips
	global TRAY_TITLE
	if(iniShowTrayTips != 1) { 
		return 
	}
	
	TrayTip, %TRAY_TITLE%, %text%	
}

;check if the monitor count changed
checkMonitorCount:
	SysGet, MonitorCount, MonitorCount
	if( MonitorCount < iniMonitorsAmount) {
		showTrayTip("restoring windows in a few seconds...")
		SetTimer, check, off
		
		;M sgBox, Monitor Count, %MonitorCount%
		Sleep, %iniPauseBeforeRestore%
		if(_winPosSavedSinceLastIdle = 1) {
			_winPosSavedSinceLastIdle := 0
			
			if( (StrLen(iniExecuteBeforeRestore) > 0) )
			{
				RunWait, %iniExecuteBeforeRestore%
			}
			
			GoSub, restoreWinPos			

			if( (StrLen(iniExecuteAfterRestore) > 0) )
			{
				RunWait, %iniExecuteAfterRestore%
			}			
		}		
		
		SetTimer, check, %iniCheckInterval%	
		
	}	
return

checkIdle() {
	global iniIdleLimit
	if(A_TimeIdle > iniIdleLimit) {
		return true
	}
}

saveWinPos:
	FileDelete, %FILE_NAME%
	file := FileOpen(FILE_NAME, "a")
	if !IsObject(file)
	{
		MsgBox, Can not open "%FILE_NAME%" for writing.
		Return
	}

	; Loop through all windows on the entire system
	WinGet, id, list,,, Program Manager
	Loop, %id%
	{
		this_id := id%A_Index%
		;WinActivate, ahk_id %this_id%
		WinGetPos, x, y, Width, Height, ahk_id %this_id%
		WinGetClass, this_class, ahk_id %this_id%
		WinGetTitle, this_title, ahk_id %this_id%

		if ( (StrLen(this_title) > 0) )
		{
			line=Title="%this_title%"`,x=%x%`,y=%y%`,width=%width%`,height=%height%`r`n
			file.Write(line)
		}
	}

	file.write(CrLf)  ;Add blank line after section
	file.Close()

	showTrayTip("saving windows done")
return

restoreWinPos:
	showTrayTip("restoring windows...")
	Sleep, 1000
	ParmVals := "Title x y height width"
 
	Loop, Read, %FILE_NAME%
	{  
		Win_Title:="", Win_x:=0, Win_y:=0, Win_width:=0, Win_height:=0
		Loop, Parse, A_LoopReadLine, CSV 
		{
			EqualPos:=InStr(A_LoopField,"=")
			Var:=SubStr(A_LoopField,1,EqualPos-1)
			Val:=SubStr(A_LoopField,EqualPos+1)
			IfInString, ParmVals, %Var%
			{
				;Remove any surrounding double quotes (")
				If (SubStr(Val,1,1)=Chr(34)) 
				{
					StringMid, Val, Val, 2, StrLen(Val)-2
				}
				Win_%Var%:=Val  
			}
		}

		If ( (StrLen(Win_Title) > 0) and WinExist(Win_Title) )
		{	
			WinMove, %Win_Title%,,%Win_x%,%Win_y%,%Win_width%,%Win_height%
		}
	}
	showTrayTip("restoring windows done")
return

removeFromAutostart:
	removeFromAutostart()
	reload
return

addToAutostart:
	addToAutostart()
	reload
return

Reload:
	Reload
return 

Exit:
	ExitApp
return