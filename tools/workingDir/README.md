Working directory tools
============

If you have to work with a lot of different files every day and you place them all into one folder, this tools will help you stay organized. Any time that you run this tool it will move all files from your working folder and place them in a backup directory.

**Example**

Your working directory:

![Your working dir before](https://github.com/XIDA/windowstools/raw/master/help/workingDir/images/workingDir_01.png)

All files and folders will be in a backup directory with the current date after running the tool:

![You backup directory](https://github.com/XIDA/windowstools/raw/master/help/workingDir/images/workingDir_02.png)



###Install###
Open cleanWorkingDir.ini and set *workingDir* and *workingBackupDir*

Example:

    workingDir="e:\[--Working--]"
    
    workingBackupDir="e:\[--Working Old--]"



###Additional settings in cleanWorkingDir.ini###

* dontMoveFoldersWithPrefix1: you can add a prefix like "--" and all folders with that prefix will not be moved to the backup folder. So if you create a folder like *--Important Project--* it will not be moved
* dontMoveFoldersWithPrefix2: same as *dontMoveFoldersWithPrefix2*
