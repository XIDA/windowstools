Working directory tools
============

If you have to work with a lot of different files every day and you place them all into one folder, this tools will help you stay organized. Any time that you run this tool it will move all files from your working folder and place them in a backup directory.

**Example**

Your working directory:

All files and folders will be placed here after running the tool:



###Install###
Open cleanWorkingDir.ini and set *workingDir* and *workingBackupDir*

Example:

    workingDir="e:\[--Working--]"
    
    workingBackupDir="e:\[--Working Old--]"



###Additional settings in cleanWorkingDir.ini###

* dontMoveFoldersWithPrefix1: you can add a prefix like "--" and all folders with that prefix will not be moved to the backup folder. So if you create a folder like *--Important Project--* it will not be moved
* dontMoveFoldersWithPrefix2: same as *dontMoveFoldersWithPrefix2*
