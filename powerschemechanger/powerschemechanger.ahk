#Persistent
#SingleInstance force
OnExit, ExitSub
Menu, Tray, Icon, high.ico

Menu, tray, NoStandard
Menu, tray, add, High performance, switchToHighPerformance  
Menu, tray, add, Power saver, switchToPowerSaver 

Menu, tray, add  ; Creates a separator line.
Menu, tray, add, Reload  
Menu, tray, add, Exit

HIGHPERFORMANCE_GUID = 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
POWERSAVER_GUID = a1841308-3541-4fab-bc81-f71556f20b4a

powerMode := 0

GoSub, enableCheckPowerScheme

return

;check every 10 seconds if the powerscheme changed
enableCheckPowerScheme:
	SetTimer, checkPowerScheme, 10000
	GoSub, checkPowerScheme	
return

checkPowerScheme:
	Line1 := "powercfg /GETACTIVESCHEME"
	RunWait, %comspec% /c %Line1% > %A_Temp%\TouchSensorTemp.txt,, HIDE
	FileReadLine, line, %A_Temp%\TouchSensorTemp.txt,1
	FileDelete, %A_Temp%\TouchSensorTemp.txt
	StringReplace line, line, `r`n, `;, All

	StringSplit, word_array, line, %A_Space%, .  ; Omits periods.
	GUID = %word_array4%

	IfInString, GUID, %HIGHPERFORMANCE_GUID%
	{
		Menu, Tray, Icon, high.ico
		powerMode := 1
	}
	else IfInString, GUID, %POWERSAVER_GUID%
	{
		Menu, Tray, Icon, low.ico
		powerMode := 0
	}
	

return

switchToHighPerformance:
	powerMode := 1
	Menu, Tray, Icon, low.ico		
	Line1 = "powercfg /SETACTIVE %HIGHPERFORMANCE_GUID%"	
	RunWait, %comspec% /c %Line1% ,, HIDE
	GoSub, checkPowerScheme
return

switchToPowerSaver:
	powerMode := 0
	Menu, Tray, Icon, low.ico		
	Line1 = "powercfg /SETACTIVE %POWERSAVER_GUID%"	
	RunWait, %comspec% /c %Line1% ,, HIDE
	GoSub, checkPowerScheme
return


Reload:
	Reload
return 

Exit:
	ExitApp
return


ExitSub:
	ExitApp 
return