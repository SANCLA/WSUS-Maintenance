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

$UpdateFromRepository = "no"


$LogFile = "Wsus-Maintenance.log"
$Log = "C:\SANCLA-scripts\WSUS-Maintenance\LOG\$LogFile"

## If the log file already exists, clear it
$LogT = Test-Path -Path $Log
If ($LogT)
{
    Clear-Content -Path $Log
}

Add-Content -Path $Log -Value "****************************************"
Add-Content -Path $Log -Value "$(Get-Date -Format G) Log started"
Add-Content -Path $Log -Value ""

If ($UpdateFromRepository)
{
	If ($UpdateFromRepository -eq "no") {
		Add-Content -Path $Log -Value "Updates switched off, skipping updates..."
	}else{
		Add-Content -Path $Log -Value "Updating from repository..."
		$source = "https://raw.githubusercontent.com/SANCLA/WSUS-Maintenance/master/Wsus-Maintenance.ps1"
		$destination = "c:\SANCLA-scripts\WSUS-Maintenance\Wsus-Maintenance.ps1"
		Write-Host "Updating file $destination ..."
		Invoke-WebRequest $source -OutFile $destination
	}
}

Function WsusMaintCmd
{
    Try
	{
		Add-Content -Path $Log -Value ""
        Add-Content -Path $Log -Value "WSUS 1 / 6: Clean Obsolete Computers..."
        Get-WsusServer -Name $WsusServer -PortNumber $WsusPort | Invoke-WsusServerCleanup -CleanupObsoleteComputers
        Add-Content -Path $Log -Value ""
        Add-Content -Path $Log -Value "WSUS 2 / 6: Clean Obsolete Updates..."
        Get-WsusServer -Name $WsusServer -PortNumber $WsusPort | Invoke-WsusServerCleanup -CleanupObsoleteUpdates
        Add-Content -Path $Log -Value ""
        Add-Content -Path $Log -Value "WSUS 3 / 6: Clean Unneeded Content Files..."
        Get-WsusServer -Name $WsusServer -PortNumber $WsusPort | Invoke-WsusServerCleanup -CleanupUnneededContentFiles
        Add-Content -Path $Log -Value ""
        Add-Content -Path $Log -Value "WSUS 4 / 6: Compress Updates..."
        Get-WsusServer -Name $WsusServer -PortNumber $WsusPort | Invoke-WsusServerCleanup -CompressUpdates
        Add-Content -Path $Log -Value ""
        Add-Content -Path $Log -Value "WSUS 5 / 6: Decline Expired Updates..."
        Get-WsusServer -Name $WsusServer -PortNumber $WsusPort | Invoke-WsusServerCleanup -DeclineExpiredUpdates
        Add-Content -Path $Log -Value ""
        Add-Content -Path $Log -Value "WSUS 6 / 6: Decline Superseded Updates..."
        Get-WsusServer -Name $WsusServer -PortNumber $WsusPort | Invoke-WsusServerCleanup -DeclineSupersededUpdates
	}
	Catch
	{
		Add-Content -Path $Log -Value ""
		Add-Content -Path $Log -Value "ERRORS FOUND:"
		Add-Content -Path $Log -Value $_
		Add-Content -Path $Log -Value ""
	}
}

## Get the WSUS service information
$SvcName = "WsusService"
$GetSvc = Get-Service -Name $SvcName


    ## Check the WSUS service status
    If ($GetSvc.Status -eq "Running")
    {
        Add-Content -Path $Log -Value "WSUS maintenance routine starting..."
        Write-Host "WSUS maintenance routine starting..."
        WsusMaintCmd
    }

    Else
    {
        Add-Content -Path $Log -Value "Error: WSUS Service is not running!"
        Write-Host "Error: WSUS Service is not running!"
    }

 
	## If log was configured stop the log
    Add-Content -Path $Log -Value ""
    Add-Content -Path $Log -Value "$(Get-Date -Format G) Log finished"
    Add-Content -Path $Log -Value "****************************************"

    ## If email was configured, set the variables for the email subject and body
    If ($SmtpServer)
    {
        $MailSubject = "WSUS Maintenance"
        $MailBody = Get-Content -Path $Log | Out-String

        ## If an email password was configured, create a variable with the username and password
        If ($SmtpPwd)
        {
            $SmtpPwdEncrypt = Get-Content $SmtpPwd | ConvertTo-SecureString
            $SmtpCreds = New-Object System.Management.Automation.PSCredential -ArgumentList ($SmtpUser, $SmtpPwdEncrypt)

            ## If ssl was configured, send the email with ssl
            If ($UseSsl)
            {
                Send-MailMessage -To $MailTo -From $MailFrom -Subject $MailSubject -Body $MailBody -SmtpServer $SmtpServer -UseSsl -Credential $SmtpCreds
            }

            ## If ssl wasn't configured, send the email without ssl
            Else
            {
                Send-MailMessage -To $MailTo -From $MailFrom -Subject $MailSubject -Body $MailBody -SmtpServer $SmtpServer -Credential $SmtpCreds
            }
        }
    
        ## If an email username and password were not configured, send the email without authentication
        Else
        {
            Send-MailMessage -To $MailTo -From $MailFrom -Subject $MailSubject -Body $MailBody -SmtpServer $SmtpServer
        }
    }
