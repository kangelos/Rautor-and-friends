
# The Rautor Windows Session recorder / auditor
## for WIN32 SESSION MONITORING Including TERMINAL SERVICES
### for child safe internet browsing
### for campus wide proxy enforcement across all support applications
### for aiding organizations in PCI compliance 


## A bit of a story line

Once upon a time there was a small poor country where a major wiretapping scandal broke out. Local authorities then required the telcos to record all actions of voice center engineers. **Rautor** was created as a tool to enforce this IT specific law. At the time there were patches for SSH to record its sessions  but nothing for windows based virtual terminals.  So I just wrote it.


### Rautor registry keys

Rautor is fully controllable via certain registry keys. The path is **HKLM\Software\Rautor** for 32bit windows. For 64bit windows please try to locate the under **HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Rautor**.  In Any case use the RRS.exe utility program to tweak these settings if you are a private user.
The keys are:

* DRIVE     		The drive where sessions must be saved. ( See above).
* AUDITDIR     		Root Directory of the auditing system. ( See above).
* SLEEP         		Seconds, snapshots are taken every SLEEP Seconds.
* QUANTUM       	Sleep quanta in Milliseconds, adjust for better key logging
  * Smaller means more duplicate keyboard presses caught. 
  * Larger means less key presses caught.
* TRIGGER		0 or 1 Should the application trigger at all? Sleeper mode!
* KEYLOGGER		0 or 1 To turn the key logging module on.
* SCREENDUMPER	0 or 1 Should Rautor take PNG screen dumps at all ?
* SCREENSCRAPER	0 or 1 Scrape screen dumps for the text contained in them.
* FULLSCRAPE		0 or 1 Scrape non visible windows also.
* WINDOWSNAMES  	Comma separated list of windows’ names that trigger Rautor. 
   * i.e. If you insert firefox there , Rautor will take screenshots only when The firefox browser is active.
* LICENSE       		The license key of your copy of Rautor.
* VERBOSE       	0 or 1 for massive event log debugging
* KEEPFILES		0 or 1 Keep a copy of uploaded files or delete them.
* LEGALWARNING	0 or 1 Display warning that the session is being logged.
* FTPSERVER		The server to upload screen shots at if set
* FTPUSER		The FTP user 
* FTPPASS		THE FTP pass
* TRAYICON		0 or 1 To display  a Tray Icon  or be completely stealth
* WEBSERVER		0 or 1 To enable the embedded web server
* WEBPORT		The web server port ( default 2222) 
* UPLOADOLDFILES	0 or 1 try to find old session data and upload them.


### Running Rautor

Inside the session recording  directory one can find PNG snapshots of the users’ desktop. Also there will be text files for each of the PNG files that contain as much textual information from the users’ opened windows as can be gleaned. Finally there exists the file ….-Keyboard.log which contains the each user’s captured keystrokes, as well as an individual keyboard log file per screen shot for your perusing.

A separate java app * **Multiviewer** * can be used to replay these dump dirs

##### The following registry keys can be changed on the fly
 
TRIGGER,		SLEEP,		QUANTUM,		VERBOSE, WINDOWSNAMES,	KEEPFILES,	SCREENSCRAPER, KEYLOGGER, SCREENDUMPER	




#### Security precautions
	One would normally want their users not to have access to their session dump dirs. To be on the safe side Pre-create the AUditDir and give only Write permissions to your users, and Full to the Administrators and System

#### Settings for Terminal Servers 
Configure the server to automatically kill disconnected sessions immediately
To make the Disconnection time less than a minute start regedit and navigate to this key: 
**HKLM\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp**
	Set MaxDisconnectionTime to 5000 decimal ( 5 seconds )


angelos karageorgiou <=> angelos at unix.gr
