send Windows status to url
==================

When Windows starts or shuts down, this tool will send the info about that to a url


**Install**
1. Edit sendWindowsStatusToUrl.ini with the url you want to be opened, make sure to place {text} in your url as a GET parameter
2. Start the exe (it will automatically add itself to the autostart)
the exe will now send text like this:
"[Computername] started", "[Computername] shutting down"

**Optional**
In sendWindowsStatusToUrl.ini you can also enable the tool to send information about Freespace and about uptime and cpu usage
the exe will then also send text like this:
"[Computername] Free Space - C: 159GB | E: 1733GB", "[Computername] Uptime: 1 Days 20 Hours 10 Minutes 25 Seconds - CPU Usage: 3%"

**Additional settings for the url in sendWindowsStatusToUrl.ini**
You can also add a few special parameters to the url:
1. {datetime}: will add a string like this to the url 18.04.2014 17:21:50
2. {random}: will add a random number between 11111 and 99999 to the url
