#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
#SingleInstance force
#Persistent ;Script nicht beenden nach der Auto-Execution-Section

SetWorkingDir %A_ScriptDir%
SetTitleMatchMode, 2

Menu, tray, NoStandard
Menu, tray, add, Reload  
Menu, tray, add, Exit
Menu, Tray, Icon, sendWindowsStatusToUrl.ico

	_startPosted 	:= 0
	_shutdownPosted := 0
	_scriptName		:= ScriptNameNoExt()

	IniRead, iniUrl, %_scriptName%.ini, general, url
	cLength := StrLen(iniUrl)
	if(cLength = 0) {
		MsgBox, Url is empty!
		ExitApp
	}

	IniRead, iniPostStart, %_scriptName%.ini, start, enabled, 1
	IniRead, iniPostStartDelay, %_scriptName%.ini, start, delay, 120

	IniRead, iniPostShutdown, %_scriptName%.ini, shutdown, enabled, 1

	IniRead, iniPostFreespace, %_scriptName%.ini, freespace, enabled, 1
	IniRead, iniPostFreespaceInterval, %_scriptName%.ini, freespace, interval, 1

	IniRead, iniPostUptime, %_scriptName%.ini, uptimeandcpuusage, enabled, 1
	IniRead, iniPostUptimeInterval, %_scriptName%.ini, uptimeandcpuusage, interval, 1

	if(A_IsCompiled) {
		GoSub, checkShortcut
	}

	GoSub, windowsStartToUrl

return

;send the windows start event to the url
windowsStartToUrl:
	if(iniPostStart = 1) {
		;wait
		waitTime := iniPostStartDelay * 1000
		Sleep, %waitTime%
		cText = %A_ComputerName% started
		sendText(cText)
	}
	_startPosted = 1
	GoSub, setupAfterStartPosted
return


setupAfterStartPosted:	
	if(iniPostShutdown) {
		OnExit, ExitSub	
	}

	if(iniPostFreespace = 1) {
		timeToCheck := iniPostFreespaceInterval * 1000
		SetTimer, freeSpace, %timeToCheck%
	}

	if(iniPostUptime = 1) {
		timeToCheck := iniPostUptimeInterval * 1000
		SetTimer, uptimeAndCPUUsage, %timeToCheck%
	}	
return

freeSpace:
	cText = %A_ComputerName% Free Space -
	DriveGet, drivesList, List, FIXED
	
	amount := 0
	Loop, Parse, drivesList
	{
		amount++
	}
	
	count := 0
	Loop, Parse, drivesList
	{
		;MsgBox, Color number %A_Index% is %A_LoopField%.
		DriveSpaceFree, freeSpace, %A_LoopField%:\
		freeSpace := Floor((freeSpace / 1024))
		cText = %cText% %A_LoopField%: %freeSpace%GB
		if(count < amount - 1) {
			cText = %cText% |
		}
		count++
		;MsgBox, %A_LoopField%: %freeSpace%GB
	}
	;M sgBox, %cText%
	sendText(cText)
return

uptimeAndCPUUsage:
	T = 20000101000000
	T += A_TickCount/1000,Seconds
	FormatTime FormdT, %T%, H 'Hours' mm 'Minutes' ss 'Seconds'
	FormatTime Days, %T%, YDay
	UpTime := Days-1 " Days " FormdT
	;M sgBox, %UpTime%
	
	FileDelete, %A_Temp%\cpusage.txt
	
	RunWait, %ComSpec% /c wmic cpu get loadpercentage > %A_Temp%\cpusage.txt,,hide	
	FileReadLine, cpuUsage, %A_Temp%\cpusage.txt, 2
	FileDelete, %A_Temp%\cpusage.txt
	cpuUsage1 = %cpuUsage%
	
	
	RunWait, %ComSpec% /c wmic cpu get loadpercentage > %A_Temp%\cpusage.txt,,hide
	FileReadLine, cpuUsage, %A_Temp%\cpusage.txt, 2
	FileDelete, %A_Temp%\cpusage.txt
	cpuUsage2 = %cpuUsage%

	RunWait, %ComSpec% /c wmic cpu get loadpercentage > %A_Temp%\cpusage.txt,,hide
	FileReadLine, cpuUsage, %A_Temp%\cpusage.txt, 2
	FileDelete, %A_Temp%\cpusage.txt
	cpuUsage3 = %cpuUsage%	
	
	cpuUsage := (cpuUsage1 + cpuUsage2 + cpuUsage3) / 3
	cpuUsage := Floor(cpuUsage)
	;M sgBox, %cpuUsage%

    cText = %A_ComputerName% Uptime: %UpTime% - CPU Usage: %cpuUsage%`% 
	;M sgBox, %cText%
	sendText(cText)
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


ExitSub:
	if (_startPosted = 0)  return 
	if (_shutdownPosted != 0) return
	
	_shutdownPosted := 1
	cText = %A_ComputerName% shutting down
	sendText(cText)	
	
	ExitApp
return


Reload:
	Reload
return 

Exit:
	ExitApp
return

sendText(cText) {
	global iniUrl
	
	StringReplace, cUrl, iniUrl, {text}, %cText%, All	
	cUrl := replaceSpecialStrings(cUrl)
	TrayTip,Url, %cUrl%
	httpQuery(result,cUrl)
}

replaceSpecialStrings(line) {
	;get current date
	FormatTime, TimeString, , dd.MM.yyyy HH:mm
	;M sgBox The current time and date (date first) is %TimeString%.	
	StringReplace, NewStr, line, {datetime}, %TimeString%, All
	
	Random, rand, 11111, 99999
	StringReplace, NewStr, NewStr, {random}, %rand%, All	

	;PC Name
	StringReplace, NewStr, NewStr, {computername}, %A_ComputerName%, All
	
	return NewStr
}

ScriptNameNoExt() {
    SplitPath, A_ScriptName,,,, ScriptNameNoExt
    return ScriptNameNoExt
}

httpQuery(byref Result, lpszUrl, POSTDATA="", HEADERS="")
{
   WebRequest := ComObjCreate("WinHttp.WinHttpRequest.5.1")
   WebRequest.Open("POST", lpszUrl)
   WebRequest.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
   WebRequest.Send(POSTDATA)
   Result := WebRequest.ResponseText
   WebRequest := ""
}