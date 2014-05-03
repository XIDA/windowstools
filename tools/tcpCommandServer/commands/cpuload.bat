@ECHO OFF
@FOR /F "skip=1 delims= " %%i in ('WMIC CPU GET LoadPercentage') do ( 
	IF %%i GEQ 0 ( @echo CPU load: %%i ) 
)