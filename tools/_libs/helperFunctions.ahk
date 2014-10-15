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

helperRandomTmpFile() {
	Random, rand, 11111111, 99999999
	scriptName := helperScriptNameNoExt()
	cFile = %A_TEMP%\%scriptName%_%rand%
	return cFile
}

helperStripTags(html) {
	return RegExReplace(html, "<.+?>" , "")
}

hasAutostartShortCut() {
	SplitPath, A_ScriptName, ,,,NNE
	ShortCutFile := A_StartUp "\" NNE ".lnk"
	SCState := FileExist(ShortCutFile) ? 1 : 0
	if SCState = 0
	{
		return false
	}
	
	return true
}

addToAutostart() {
	SplitPath, A_ScriptName, ,,,NNE
	ShortCutFile := A_StartUp "\" NNE ".lnk"
	SCState := FileExist(ShortCutFile) ? 1 : 0
	if SCState = 0
	{
		FileCreateShortcut, %A_ScriptFullPath%, %ShortCutFile%, %A_WorkingDir%	
	}
}

removeFromAutostart() {
	SplitPath, A_ScriptName, ,,,NNE
	ShortCutFile := A_StartUp "\" NNE ".lnk"
	SCState := FileExist(ShortCutFile) ? 1 : 0
	if SCState = 1
	{
		FileDelete, %ShortCutFile%
	}
}
