<#
.DESCRIPTION
	Simple workaround wrapper function to list and connect wifi-networks using netsh.exe
#>
Function Initiate-WifiMan {
	param(
		[String]$Action = "list",
		[String]$WifiName = ""
	)

	Function Prompt-Connection {

		# NOTE: This code works for me right now but can have some more validations and corrections.

		# TODO: First you should check whether the interface is [UP] or [DOWN] then only proceed & give graceful message.
		# TODO: You can even make a funcion to enable and disable the interface.
		# FIX: What if you are already connected to a network?

		$WifiData = @{}
	
		# Creating hash-table of available wifi(s)
		try {
			for ($i = 1; $i -le 10; $i=$i+2 ) {
				$WifiName = $(netsh wlan show networks | findstr.exe SSID).Split(':')[$i].Trim().ToString()
				$WifiData[$i] = $WifiName
			}

		} catch {
			#Write-Error "Details : $_"
			#return # I think using return will throw you out of the overall script block, so for not it's better to catch nothing
		}

		# TODO: Only run the following code if the $WidiData is not empty.

		# Prompting user to select a choice and conncet to that network
		try {
			Write-Host $WifiData
			[Int]$GetNum = Read-Host "Enter You Choice: "
			netsh wlan connect $WifiData.$GetNum
		} catch {
			Write-Error "Details : $_"
		}
	
	}

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
		"w" {
			Prompt-Connection
			
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

Function Prompt-WifiConnection {
	Initiate-WifiMan w
}
Set-Alias ww Prompt-WifiConnection

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

