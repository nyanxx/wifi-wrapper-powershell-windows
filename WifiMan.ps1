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
	
		if ($WifiData.Count -ne 0) {
			# Prompting user to select a choice and conncet to that network
			try {
				# TODO: Rather than just printing the hast-table you can present it in a more proper manner and numbering( with logic )
				Write-Host $WifiData
				# TODO: You can add validation for $GetNum, whether it's a number of something else
				[Int]$GetNum = Read-Host "Enter You Choice: "
				netsh wlan connect $WifiData.$GetNum
			} catch {
				Write-Error "Details : $_"
			}
		} else {
    			Write-Host "No available Wi-Fi network" -ForegroundColor Red
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
		{$_ -eq "end" -or $_ -eq "down" -or $_ -eq "e" -or $_ -eq "d" } {
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

#Function Connect-WifiSpecified($spe) {  wifi connect $spe }
#Set-Alias wc Connect-WifiSpecified

Function Prompt-WifiConnection {
	Initiate-WifiMan w
}
Set-Alias ww Prompt-WifiConnection

# Check Internet Connection Using Test-NetConncetion cmdlet of PowerShell
Function Check-NetworkConnection {
	$ConnectionName = &{try {(netsh wlan  show interface | findstr.exe SSID)[0].Split(":")[1].Trim()} catch { Write-Output $null }}

	if (Test-NetConnection | Select-Object -ExpandProperty PingSucceeded) {
		Write-Host "You are connected to Internet through `"$ConnectionName`" Wi-Fi Network!" -ForegroundColor Green
	} elseif ($ConnectionName -ne $null) {
		Write-Host "You are NOT connected to Internet BUT connected to `"$ConnectionName`" Wi-Fi Network!" -ForegroundColor Magenta
	} else {
		Write-Host "You have no Internet connection" -ForegroundColor Red
	}
}
Set-Alias cnc Check-NetworkConnection

# Check if connected to any wifi network (doesn't check the internet connection, for that use `cnc`)
Function Check-WifiConnection {
	try { 
		$wifiname = (netsh wlan  show interface | findstr.exe SSID)[0].Split(":")[1].Trim()
		Write-Host "You are connected to `"$wifiname`"" -ForegroundColor Green
	} catch { Write-Host "You are NOT connected to any Wifi Network" -ForegroundColor Red }
}
Set-Alias cwc Check-WifiConnection
