FileZilla Launcher
============

Adds a menu to the tray to quickly launch your most important FileZilla FTP Connections.

![FileZilla Launcher](https://raw.githubusercontent.com/XIDA/windowstools/master/help/filezillaLauncher/images/filezillaLauncher_01.png)


###Install###
1. Edit filezillaLauncher.ini 
	* sitemanagerPath: add the path to your sitemanager.xml file (this is usually located here *C:\Users\USERNAME\AppData\Roaming\FileZilla\sitemanager.xml*)
	* filezillaExe: add the path to the FileZilla.exe file (this is usually located here *C:\Program Files (x86)\FileZilla FTP Client\filezilla.exe*)

	**So your ini file might look like this**


	`sitemanagerPath="C:\Users\xida\AppData\Roaming\FileZilla\sitemanager.xml"


	filezillaExe="C:\Program Files (x86)\FileZilla FTP Client\filezilla.exe"
	`
	
2. launch the .exe file and you will find it in the tray
3. right click it and choose *Settings*
4. choose the ftp connections you want to be visible in the right click menu and click *Save*
5. open the right click menu again and you will find the entries you added on top of the menu
