; loading correct ini
; you can either use %INI_FILE% or COMPUTERNAME_%INI_FILE%
; sometimes one script wants to use the ini file of another script
; then it should send scriptName
helperIniFile(scriptName = "") {
	if(scriptName = "") {
		iniFile			:= helperScriptNameNoExt() . ".ini"
	} else {
		iniFile			:= scriptName . ".ini"
	}
	
	iniFileLocal 	:= A_ComputerName . "_" . iniFile
	if(FileExist(iniFileLocal)) {
		iniFile := iniFileLocal
	}
	return iniFile
}

helperScriptNameNoExt() {
    SplitPath, A_ScriptName,,,, ScriptNameNoExt
    return ScriptNameNoExt
}


helperProcessExist(PidOrName) {
	Process, Exist, %PidOrName%
	return ErrorLevel
}

helperContainsSubstring(cText, substring) {
	IfInString, cText, %substring%
	{
		return true
	}
	
	return false
}
