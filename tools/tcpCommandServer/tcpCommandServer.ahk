#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
#SingleInstance force
#Persistent ;Script nicht beenden nach der Auto-Execution-Section
SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2

#include libs/WS.ahk
#include %A_ScriptDir%\..\_libs\helperFunctions.ahk

Menu, tray, NoStandard
Menu, tray, add, Reload  
Menu, tray, add, Exit
Menu, Tray, Icon, tcpCommandServer.ico


_iniFile 	:= helperIniFile()
_authorized := false

IniRead, password, 		%_iniFile%, settings, password
IniRead, port, 			%_iniFile%, settings, port
IniRead, autostart,		%_iniFile%, settings, autostart, 0
IniRead, commandsDir, 	%_iniFile%, directories, commands, commands

if(A_IsCompiled) {
	if(autostart = 1) {
		GoSub, checkShortcut
	}
}
	
;WS_LOGTOCONSOLE := gConsole 
WS_Startup()
server := WS_Socket("TCP", "IPv4") 
WS_Bind(server, "0.0.0.0", port) 
WS_Listen(server)
WS_HandleEvents(server)

return

;check autostart shortcut
checkShortcut:
	SplitPath, A_ScriptName, ,,,NNE
	ShortCutFile := A_StartUp "\" NNE ".lnk"
	SCState := FileExist(ShortCutFile) ? 1 : 0
	if SCState = 0
	{
		FileCreateShortcut, %A_ScriptFullPath%, %ShortCutFile%, %A_WorkingDir%	
	}
return

Reload:
	Reload
return 

Exit:
	ExitApp
return


String_Trim(_String, _TrimChars = " `n`r`t")
{
    Loop, Parse, _String, ¤, %_TrimChars%
        Return A_LoopField
    Return _String
}

WS_OnRead(socket)
{	
	global commandsDir
	global password
	global _authorized
	
	WS_Recv(socket, cMessage)
	
	cMessage := String_Trim(cMessage)
	
	;opened from a webbrowser
	IfInString, cMessage, GET
	{
		StringSplit, testArray, cMessage, %A_SPACE%
		cMessage = %testArray2%
		StringReplace, cMessage, cMessage, /
		StringReplace, cMessage, cMessage, `%20 , %A_SPACE%, 1
	}
	
	;M sgBox, >%cMessage%<
	StringSplit, cArray, cMessage, /,
	cLenght = %cArray0%

	cWait		 		= %cArray4%	
	cCommandParameters 	= %cArray3%		
	cCommand 			= %cArray2%	
	cPassword 			= %cArray1%
	
	if(cPassword != password) {
		msg = wrong password`n
		WS_Send(socket,msg)
		WS_CloseSocket(socket)
		return 1		
	}	
	
	ContentType 	= Content-Type: text/html
	returnString 	= HTTP/1.0 200 OK`n`r%ContentType%`n`r`n`r<html><body>	
	
	;M sgBox, >%cCommand%<
	if(Strlen(cCommand) = 0) {
		returnString 	= %returnString%%A_Computername% Commands <br/>
		Loop, %commandsDir%\*.*
		{
			SplitPath, A_LoopFileLongPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			returnString = %returnString%<a href="/%cPassword%/%OutNameNoExt%" target="_self">%OutFileName%</a><br/>
		}
		
	} else {

		found := false
		Loop, %commandsDir%\*.*, , 1  ; Recurse into subfolders.
		{
			SplitPath, A_LoopFileLongPath, OutFileName, OutDir, OutExtension, OutNameNoExt, OutDrive
			if(OutNameNoExt = cCommand) {
				found := true
				;M sgBox splitpath (file name only): %OutNameNoExt%			
				tmpFile := helperRandomTmpFile()
				;tmpFile = test.txt
				;M sgBox, %tmpFile%
				;Run, %A_LoopFileLongPath%
				FileDelete, %tmpFile%

				
				if(cWait = "nowait") {
					Run, "%A_LoopFileLongPath%" "%cCommandParameters%",,hide
				} else {
					RunWait, %comspec% /c ""%A_LoopFileLongPath%" "%cCommandParameters%"" > %tmpFile%,, hide
				}			
				
				;msg = executed command`n
				;WS_Send(socket,msg)				

				FileRead, contents, %tmpFile%				
				contents = %contents%
				
				if not ErrorLevel  ; Successfully loaded.			
				{
					if(StrLen(contents) > 0) {				
						returnString = %returnString%<textarea style="width:100`%; height:100`%">%contents%</textarea>

						FileDelete, %tmpFile%
					}
				}
			}			
		}
		if(!found) {
			returnString = %returnString%command not found`n
		}
	}
	
	returnString = %returnString%</body></html>
	WS_Send(socket,returnString)	
	WS_CloseSocket(socket)		
	return 1
}



WS_OnConnect(socket)
{
	return 1 ;Event wurde NICHT bearbeited
}

WS_OnError()
{
	global gRegistered	
	global gRestartOnError
	
	;T rayTip, server, ERROR
	
	if(gRestartOnError = 1) {
		;if(gRegistered = 1) {
			;T rayTip, server, ERROR restarting...
			Sleep, 1000
			Reload
		;}
	}
}

WS_OnClose(socket)
{
	
	return 1

}