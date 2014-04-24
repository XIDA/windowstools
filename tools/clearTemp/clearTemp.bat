@echo off
REM downloaded files
del C:\Users\%USERNAME%\Downloads\*.* /F /S /Q

REM delete temp files of different programs
del C:\Users\%USERNAME%\AppData\Local\Temp\*.* /F /S /Q
del "C:\Users\%USERNAME%\AppData\Local\Microsoft\Windows\Explorer\*.*" /F /S /Q
del C:\Users\%USERNAME%\AppData\Local\Microsoft\Windows\WER\*.* /F /S /Q

REM Screenpresso software
del C:\Users\%USERNAME%\Pictures\Screenpresso\*.* /F /S /Q

del "C:\Users\admin-sama\AppData\Roaming\Microsoft\Windows\Cookies\Cache\*.*" /F /S /Q
del C:\ProgramData\Microsoft\Windows\WER\*.* /F /S /Q

REM Notepad++ FTP cache
del "C:\Users\%USERNAME%\AppData\Roaming\Notepad++\plugins\config\NppFTP\Cache" /F /S /Q

REM wamp webserver temp files
del E:\wamp\tmp\*.* /F /S /Q

REM run this line one time and select everything you want to clean
REM cleanmgr /sageset:1

REM then enable this line
cleanmgr /sagerun:1


REM unused
REM del "C:\Users\%USERNAME%\AppData\Roaming\Adobe\Premiere Pro\5.0\Metadata Caches\*.*" /F /S /Q
REM del "C:\Users\%USERNAME%\Documents\Adobe\After Effects CS4\Media Cache Files\*.*" /F /S /Q
REM del "C:\Users\%USERNAME%\AppData\Local\Autodesk\3dsMaxDesign\2010 - 64bit\enu\temp\*.*" /F /S /Q
REM del "C:\Users\%USERNAME%\AppData\Local\Autodesk\3dsMax\2010 - 64bit\enu\temp\*.*" /F /S /Q
REM del "C:\Users\%USERNAME%\AppData\Local\Autodesk\3dsMax\2010 - 64bit\enu\temp\*.*" /F /S /Q



