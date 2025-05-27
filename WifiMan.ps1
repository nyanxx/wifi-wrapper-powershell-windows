<#
.DESCRIPTION
	Simple workaround wrapper function to list and connect wifi-networks using netsh.exe
#>
Function Initiate-WifiMan {
	param(
		[String]$Action = "list",
		[String]$WifiName = ""
	)

	switch ($Action) {
		{$_ -eq "list" -or $_ -eq "l"}  {
			netsh wlan show networks
		}
		{$_ -eq "connect" -or $_ -eq "c"} {
			if ($WifiName -eq "") {
				Write-Host "Error: Empty WifiName Parameter : Enter -WifiName Parameter and Try Again!" -ForegroundColor Red
				return
			}
			netsh wlan connect name=$WifiName
		}
		{$_ -eq "end" -or $_ -eq "down" -or $_ -eq "d"} {
			netsh wlan disconnect
		}
		default {
			Write-Error "There was some problem with WifiMan!"
		}
	}
}
Set-Alias wifi Initiate-WifiMan
Set-Alias w Initiate-WifiMan

Function Connect-WifiSpecified($spe) {  wifi connect $spe }
Set-Alias wc Connect-WifiSpecified

# Check Net Connection Using Test-NetConncetion cmdlet of PowerShell
Function Check-NetworkConnection {
	$ConnectionName = &{try {(netsh wlan  show interface | findstr.exe SSID)[0].Split(":")[1].Trim()} catch {Write-Output "Not Connected!"}}

	if (Test-NetConnection | Select-Object -ExpandProperty PingSucceeded) {
		Write-Host "You are connected to $ConnectionName network!" -ForegroundColor Green
	} else {
		Write-Host "You are not connected to any network!" -ForegroundColor Red
	}
}
Set-Alias cnc Check-NetworkConnection

