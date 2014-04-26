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

ScriptNameNoExt() {
    SplitPath, A_ScriptName,,,, ScriptNameNoExt
    return ScriptNameNoExt
}