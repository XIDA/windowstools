open url
============

This tool will open urls in the background.
This will come in handy in certain scenarious like backup programs where you can only launch a .exe file when the backup is done. With this tool you can inform your webservices about updates and finished backups.

###Install###
1. Copy the openurl.exe and openurl.txt to your desired location
2. rename both files to whatever you like, just be sure to give them the same name (like test.exe and test.txt)
3. open the .txt file and and add as many urls as you like (one url per line)

###Additional settings for the urls###
You can also add a few special parameters to the url:

* {datetime}: will add a string like this to the url 18.04.2014 17:21:50
* {random}: will add a random number between 11111 and 99999 to the url
* {computername}: will add the name of the computer to the url

###Example urls###
    http://yourdomain.com/update.php?computer={computername}&date={datetime}&random={random}



###Alternative usage###
Just add the urls to open as command line parameters:

    openurl.exe http://www.google.com http://www.yahoo.com http://www.bing.com



