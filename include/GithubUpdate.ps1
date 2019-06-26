If ($UpdateFromRepository -eq "no") {
		Add-Content -Path $Log -Value "Updates switched off, skipping updates..."
}else{
		Add-Content -Path $Log -Value "Updating from repository..."
		$source = "https://raw.githubusercontent.com/SANCLA/WSUS-Maintenance/master/Wsus-Maintenance.ps1"
		$destination = "c:\SANCLA-scripts\WSUS-Maintenance\Wsus-Maintenance.ps1"
		Write-Host "Updating file $destination ..."
		Invoke-WebRequest $source -OutFile $destination
}