; default tray entries that should be there for all tools

Menu, tray, NoStandard

return

addDefaultTray:

	Menu, tray, add  ; Creates a separator line.
	Menu, tray, add, Reload  
	Menu, tray, add, Exit
		
	Menu, tray, Icon, Reload, shell32.dll, 239
	Menu, tray, Icon, Exit, shell32.dll, 113
return

Reload:
	Reload
return 

Exit:
	ExitApp
return