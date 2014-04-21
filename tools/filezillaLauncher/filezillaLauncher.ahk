#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
#SingleInstance force
#Persistent 
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2

#Include %A_ScriptDir%\includes\xpath.ahk

Menu, tray, NoStandard
Menu, tray, Icon, filezillaLauncher.ico,  1

INI_FILE := iniFile()
;M sgBox, %INI_FILE%

IniRead, sitemanagerPath, %INI_FILE%, settings, sitemanagerPath
IniRead, FileZillaExePath, %INI_FILE%, settings, filezillaExe
IniRead, enableF11Shortcut, %INI_FILE%, settings, enableF11Shortcut, 0

if(enableF11Shortcut = 1) {
	Hotkey, F11, f11Pressed
}


Loop, 1000
{
	IniRead, OutputVar, %INI_FILE%, sites, %A_index%	
	if(OutputVar = "ERROR") {
		continue
	}
	;M sgBox, The value is %OutputVar%.
	Menu, tray, add, %OutputVar%, tryMenuSelected	
}

Menu, tray, add  ; Creates a separator line.
Menu, tray, add, Settings, showSettings 
Menu, tray, add  ; Creates a separator line.
Menu, tray, add, Reload  
Menu, tray, add, Exit

return

showSettings:

	totalSites := 0	
	
	Gui, Add, ListView, h330 w470 x0 y0 gMyListView NoSortHdr checked, Sites
	Gui, Add, StatusBar,, loading sites... %totalSites%
	Gui, Add, Button, x430 Default gSaveSettings vSaveButton, Save
	GuiControl, Disable, SaveButton 
	
	Gui, Show,, fileZilla Launcher
	
	StringLen, cLength, sitemanagerPath
	;M sgBox, %cLength%
	if(cLength > 0) {
		cPath = %sitemanagerPath%
	} else {
		cPath = sitemanager.xml
	}
	
	;M sgBox, %cPath%
	xpath_load(xml, cPath)	
	
	cAmount := xpath(xml,"/FileZilla3/Servers/Server/count()")
	;M sgBox, %cAmount%
	Loop, %cAmount% {

		cVal := xpath(xml, "/FileZilla3/Servers/Server[" . A_index . "]/Name/text()")
		cVal = %cVal%

		;Gui, Add, Checkbox, v%A_index%, %cVal%
		isInSettings := isInSettings(cVal)
		;M sgBox, %isInSettings%
		;M sgBox, %cVal%
		if(isInSettings) {
			LV_Add("Check", cVal)
		} else {
			LV_Add("", cVal)
		}		
		updateTotalSites()
		
		;check bookmarks
		cIndex := A_index
		ccAmount := xpath(xml, "/FileZilla3/Servers/Server[" . A_index . "]/Bookmark/count()")
		;M sgBox, %ccAmount%
		if(ccAmount > 0) {
			Loop, %ccAmount% {
				
				ccVal := xpath(xml, "/FileZilla3/Servers/Server[" . cIndex . "]/Bookmark[" . A_index . "]/Name/text()")
				ccVal = %cVal%/%ccVal%

				;Gui, Add, Checkbox, v%A_index%, %cVal%
				isInSettings := isInSettings(ccVal)
				;M sgBox, %isInSettings%
				if(isInSettings) {
					LV_Add("Check", ccVal)
				} else {
					LV_Add("", ccVal)
				}				
				updateTotalSites()
			}
		}
	}
	
	;we need to check <folder> too
	cAmount := xpath(xml,"/FileZilla3/Servers/Folder/count()")
	;M sgBox, %cAmount%
	Loop, %cAmount% {

		cVal := xpath(xml, "/FileZilla3/Servers/Folder[" . A_index . "]/text()")
		cVal = %cVal%	
		
		StringSplit, word_array, cVal, <

		Loop, %word_array0%
		{
			cVal := word_array%a_index%
			break
		}

		;M sgBox, Phase 1 >%cVal%<
		
		StringReplace,cVal,cVal,`n,,A
		StringReplace,cVal,cVal,`r,,A

		;M sgBox, Phase 2 >%cVal%<		
		
		cIndex := A_index
		ccAmount = 0
		ccAmount := xpath(xml, "/FileZilla3/Servers/Folder[" . A_index . "]/Server/count()")
		;M sgBox, %ccAmount%
		if(ccAmount > 0) {
			Loop, %ccAmount% {
				
				ccVal := xpath(xml, "/FileZilla3/Servers/Folder[" . cIndex . "]/Server[" . A_index . "]/Name/text()")
				ccVal = %cVal%/%ccVal%

				;Gui, Add, Checkbox, v%A_index%, %cVal%
				isInSettings := isInSettings(ccVal)
				;M sgBox, %ccVal%
				;M sgBox, %isInSettings%
				if(isInSettings) {
					LV_Add("Check", ccVal)
				} else {
					LV_Add("", ccVal)
				}				
				updateTotalSites()
			
				;check bookmarks
				ccIndex := A_index
				cccAmount := xpath(xml, "/FileZilla3/Servers/Folder[" . cIndex . "]/Server[" . ccIndex . "]/Bookmark/count()")
				;M sgBox, Bookmarks %ccVal% %cccAmount%
				if(cccAmount > 0) {
					Loop, %cccAmount% {						
						cccVal := xpath(xml, "/FileZilla3/Servers/Folder[" . cIndex . "]/Server[" . ccIndex . "]/Bookmark[" . A_index . "]/Name/text()")
						cccVal = %ccVal%/%cccVal%

						;Gui, Add, Checkbox, v%A_index%, %cVal%
						isInSettings := isInSettings(cccVal)
						;M sgBox, %isInSettings%
						if(isInSettings) {
							LV_Add("Check", cccVal)
						} else {
							LV_Add("", cccVal)
						}				
						updateTotalSites()
					}
				}
			}			
		}		
		
	}

	SB_SetText("loading done.") 
	GuiControl, Enable, SaveButton 
	
return

tryMenuSelected:
	;M sgBox You selected %A_ThisMenuItem% from menu %A_ThisMenu%.
	runString = "%FileZillaExePath%" --site="0/%A_ThisMenuItem%"
	;M sgBox, %runString%
	Run, %runString%	
	
return

f11Pressed:	
	WinGetClass explorerClass, A
	Send, {F4}
	Send, {ESC}
	ControlGetText cPath, Edit1, ahk_class %explorerClass%

	cLenght := StrLen(cPath) 
	if(cLenght > 0) {
		;M sgBox, %cPath%
		WinActivate, - FileZilla
		ControlClick, Edit5, - FileZilla
		ControlSetText, Edit5, %cPath%, - FileZilla
		ControlClick, Edit5, - FileZilla
		Send, {End}
		Send, {Enter}
	}
	
return

MyListView:
		 
if A_GuiEvent = DoubleClick
{
	GoSub, SaveSettings

}
return

SaveSettings:
	IniDelete, %INI_FILE%, sites

	Loop % LV_GetCount()
	{
		SendMessage, 4140, A_Index - 1, 0xF000, SysListView321
		IsChecked := (ErrorLevel >> 12) - 1 
		;M sgBox, %IsChecked%

	
		LV_GetText(RetrievedText, A_Index)		
		;M sgBox, %RetrievedText% %IsChecked%
		RetrievedText = %RetrievedText%
		
		if(IsChecked = 1) {
			IniWrite, %RetrievedText%, %INI_FILE%, sites, %A_Index%
			;M sgBox, %RetrievedText% %A_Index%
		}
		IsChecked := 0
		
		
	}
	reload	
return


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

updateTotalSites() {
	global totalSites
	
	totalSites := totalSites + 1
	newText = loading Sites... %totalSites%
	SB_SetText(newText) 
}

isInSettings(cVal) {
	global INI_FILE
	
	Loop, 1000
	{
		IniRead, OutputVar, %INI_FILE%, sites, %A_index%	
		
		if(OutputVar = cVal) {
			return true
			break
		}
	
	}
	
	return false
}

ScriptNameNoExt() {
    SplitPath, A_ScriptName,,,, ScriptNameNoExt
    return ScriptNameNoExt
}


Reload:
	Reload
return 

Exit:
	ExitApp
return
