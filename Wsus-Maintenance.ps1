[CmdletBinding()]
Param(
    [parameter(Mandatory=$True)]
    [alias("Server")]
    $WsusServer,
    [parameter(Mandatory=$True)]
    [alias("Port")]
    $WsusPort,
    [alias("Update")]
    $UpdateFromRepository,
    [alias("SendTo")]
    $MailTo,
    [alias("From")]
    $MailFrom,
    [alias("Smtp")]
    $SmtpServer,
    [alias("User")]
    $SmtpUser,
    [alias("Pwd")]
    $SmtpPwd,
    [switch]$UseSsl)

$LogFile = "Wsus-Maintenance.log"
$Log = "C:\SANCLA-scripts\WSUS-Maintenance\LOG\$LogFile"

## If the log file already exists, clear it
$LogT = Test-Path -Path $Log
If ($LogT)
{
    Clear-Content -Path $Log
}

Add-Content -Path $Log -Value "****************************************"
Add-Content -Path $Log -Value "     SANCLA WSUS Maintenance script     "
Add-Content -Path $Log -Value "****************************************"
Add-Content -Path $Log -Value " $(Get-Date -Format G) Log started"
Add-Content -Path $Log -Value ""

# Updating the script files
Add-Content -Path $Log -Value "Downloading latest version from the repository"
. “C:\SANCLA-scripts\WSUS-Maintenance\include\GithubUpdate.ps1”

# Starting the WSUS Cleanup script
Add-Content -Path $Log -Value "Starting the WSUS Cleanup script"
. “C:\SANCLA-scripts\WSUS-Maintenance\include\WsusServerCleanup.ps1”

# Starting WSUS Database maintenance
. “C:\SANCLA-scripts\WSUS-Maintenance\include\Invoke-WSUSDBMaintenance.ps1”
