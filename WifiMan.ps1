<#
.SYNOPSIS
Simple workaround wrapper function to list and connect wifi-networks using netsh.exe

.DESCRIPTION
- Wrapper based on netsh.exe Windows utility.
- Provide feature to list and connect wifi-networks through wifi-name. Example: wifi connect "wifi-name"
- Aliases made things very simple and fast (at least for me).

.PARAMETER Action
[l]ist : List wifi networks. (DEFAULT)
[c]onnect : Enable connection to available network.
[e]nd or [d]own : Disconnect network connection.
w : Prompt user a list of available network and connection choice.

.PARAMETER WifiName
Your wifi-name goes here

.EXAMPLE
NOTE: Example are shown using aliases for simpilicity
wifi OR w				# List networks
wifi list OR w l			# List networks
wifi connect "wifi-name"		# Connects to specified wifi-name
w c wifi-name			# Connects to specified wifi-name
w d OR w e				# Disconnect wifi connection
w w OR ww				# Prompt user to connect to a network


#>
Function Initiate-WifiMan {
	param(
		[String]$Action = "list",
		[String]$WifiName = ""
	)

	Function Prompt-Connection {

		# TODO: Give message if you are already connected to a wifi-network.
		
		# If NetAdapter Off - End Script
		try {
			$NetAdapterRadioSoftStatus = ( netsh wlan show interface | findstr.exe Software ).Trim().Split(' ')[1].ToString()
			if($NetAdapterRadioSoftStatus -eq "Off"){
				Write-Host "Wi-Fi NetAdapter is Disconnected!" -ForegroundColor Red
				return $null
			}
		} catch {
			# Do nothing here! ; Maybe i can use -ErrorAction SilentlyContinue or -ErrorAction Continue for error instead of try-catch if possible  
		}

		$WifiList = @()
		try {
			$Index = 1
			$WifiCollection = netsh wlan show networks | findstr.exe SSID
			
			foreach($Wifi in $WifiCollection) {
				$WifiName = $Wifi.Split(':').Trim()[1].ToString()
				$WifiList += [PSCustomObject]@{
					Number = $Index
					"Wifi-Name" = $WifiName
				}
				$Index++
				
			}
		} catch {
			Write-Error "Error fetching Wi-Fi networks: $_"
			return $null
		}
	
		if ($WifiList.Count -ne 0) {
			# Prompting user to select a choice and connect to that network
			Write-Host "`nAvailable Wi-Fi Networks:"
			$WifiList | Format-Table -AutoSize | Out-Host
			

			while($true) {
				try {
					[Int]$ChoiceNum = Read-Host "Enter Your Choice (Number)"
					if(!$ChoiceNum){throw}
					if($ChoiceNum -gt $WifiList.Count -or $ChoiceNum -le 0){throw}
					$WifiSelectedObject = $WifiList | Where-Object {$_.Number -eq $ChoiceNum}
					netsh wlan connect $WifiSelectedObject."Wifi-Name"
					break
				} catch {
					Write-Host "Enter a valid number! or use 'ctrl + c' to exit" -ForegroundColor Red
				}
			}
		} else {
    			Write-Host "No available Wi-Fi network" -ForegroundColor Red
			return $null
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

Function Prompt-WifiConnection {
	Initiate-WifiMan w
}
Set-Alias ww Prompt-WifiConnection

# Check Internet Connection Using Test-NetConncetion cmdlet of PowerShell
Function Check-InternetConnection {
	$ConnectionName = &{try {(netsh wlan  show interface | findstr.exe SSID)[0].Split(":")[1].Trim()} catch { Write-Output $null }}

	if (Test-NetConnection | Select-Object -ExpandProperty PingSucceeded) {
		Write-Host "You are connected to Internet through `"$ConnectionName`" Wi-Fi Network!" -ForegroundColor Green
	} elseif ($ConnectionName -ne $null) {
		Write-Host "You are NOT connected to Internet BUT connected to `"$ConnectionName`" Wi-Fi Network!" -ForegroundColor Magenta
	} else {
		Write-Host "You have no Internet connection" -ForegroundColor Red
	}
}
Set-Alias cic Check-InternetConnection

# Check if connected to any wifi network (doesn't check the internet connection, for that use `cic`)
Function Check-WifiConnection {
	try { 
		$wifiname = (netsh wlan  show interface | findstr.exe SSID)[0].Split(":")[1].Trim()
		Write-Host "You are connected to `"$wifiname`"" -ForegroundColor Green
	} catch { Write-Host "You are NOT connected to any Wifi Network" -ForegroundColor Red }
}
#Set-Alias cwc Check-WifiConnection
Set-Alias cnc Check-WifiConnecton
