#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.
#SingleInstance force
#Persistent ;Script nicht beenden nach der Auto-Execution-Section

SetWorkingDir %A_ScriptDir%

_addTaskSchedulerFilename	= taskScheduler.xml

FileDelete, %_addTaskSchedulerFilename% 

;create reg file
FileRead, cContents, templates\%_addTaskSchedulerFilename%

dateToSend 	+= 1, Minutes
;2014-04-27T16:40:41
FormatTime,timeString,%dateToSend%,yyyy-MM-ddTHH:mm:ss
StringReplace, cContents, cContents, {datetime} , %timeString%, All

cDir = %A_ScriptDir%	
StringReplace, cContents, cContents, {currentfolder} , %cDir%, All

FileAppend, %cContents%, %_addTaskSchedulerFilename%	

RunWait %comspec% /c schtasks /delete /TN ftpbackup /F
RunWait %comspec% /c schtasks /create /XML taskScheduler.xml /TN ftpbackup

FileDelete, %_addTaskSchedulerFilename% 
ExitApp
