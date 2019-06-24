# WSUS-Maintenace
WSUS configure and maintain documentation/solution

The script is an adaptation of the original script by Mike Galvin.
It has been enhanced and further developed.

# Features and Requirements
* Auto updating with the Github repository (https://github.com/SANCLA/WSUS-Maintenance)
* The script will run the WSUS server cleanup process, which will delete obsolete updates, as well as declining expired and superseded updates. 
* The script can optionally create a log file and e-mail the log file to an address of your choice. 
* The script can be run locally on a WSUS server, or on a remote sever. 
* The script requires that the WSUS management tools be installed. 
* The script has been tested on Windows 10 and Windows Server 2016. 


# How to install
1. Create a new folder
   C:\SANCLA-scripts\WSUS-Maintenance
2. Copy the contents of this repository to the newly created folder
3. Create a new task in Windows Task Planner to run daily or weekly:
  * Run as SYSTEM user, run with highest privileges
  * Program/script: powershell.exe
  * Add arguments: -ExecutionPolicy Bypass -Command "& 'C:\SANCLA-scripts\WSUS-Maintenance\Wsus-Maintenance.ps1' -Server [your-wsus-server] -Port 8530 -L C:\SANCLA-scripts\WSUS-Maintenance\LOG"
  * Replace -Server [your-wsus-server]  with your WSUS server, eg wsus01.domain.local
  * Replace -Port 8530 with the used WSUS port. Default is 8530. Check IIS binding for the correct port...

# Credits
* https://gallery.technet.microsoft.com/scriptcenter/WSUS-Maintenance-w-logging-d507a15a

# Documentation
 
## Generating A Password File
The password used for SMTP server authentication must be in an encrypted text file. To generate the password file, run the following command in PowerShell, on the computer that is going to run the script and logged in with the user that will be running the script. When you run the command you will be prompted for a username and password. Enter the username and password you want to use to authenticate to your SMTP server.  
Please note: This is only required if you need to authenticate to the SMTP server when send the log via e-mail.  

1. $creds = Get-Credential
2. $creds.Password | ConvertFrom-SecureString | Set-Content c:\scripts\ps-script-pwd.txt

After running the commands, you will have a text file containing the encrypted password.  
When configuring the -Pwd switch enter the path and file name of this file.
 
## Configuration
The table below shows all the command line options available with descriptions and example configurations.
 
Command Line Switch | Mandatory	| Description | Example
--- | --- | --- | ---
-Server | Yes | The WSUS server that should be cleaned.	| wsus01.domain.local
-Port | Yes | The port that the WSUS service is running on. | 8530
-L | No	| Location to store the optional log file. The name of the log file is generated automatically.	| C:\foo
-SendTo	| No | The email address to send the log file to. | me@contoso.com
-From | No* | The email address that the log file should be sent from. | noreply@contoso.com
 

\* This switch isn’t mandatory but is required if you wish to email the log file.
 
