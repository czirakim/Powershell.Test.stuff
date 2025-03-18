$url_list = @("http://acme.com",
              "http://google.com" 
		  )


function Get-Dns {

	$defaultGateway = Get-NetRoute -DestinationPrefix "0.0.0.0/0" |  Where-Object -FilterScript { $_.NextHop -Ne "0.0.0.0" } |  Select-Object -ExpandProperty "NextHop"

	# Identify the default network interface
	$defaultInterface = Get-NetRoute -DestinationPrefix "0.0.0.0/0" | Where-Object { $_.NextHop -eq $defaultGateway }

	# Get the DNS server addresses for the default network interface
	$dnsServers = Get-DnsClientServerAddress -InterfaceAlias $defaultInterface.InterfaceAlias

	# Display the default DNS servers
	Write-Host -ForegroundColor Green "`n Default DNS Servers: $($dnsServers.ServerAddresses)"
	

	# Get all network configurations excluding the default interface
	$networkConfigurations = Get-NetIPConfiguration | Where-Object { $_.InterfaceAlias -ne $defaultInterface.InterfaceAlias }
	# Filter out configurations where the network adapter is disconnected or DNS server is null

	$VpnNetworkConfigurations = $networkConfigurations | Where-Object { $_.NetAdapter.Status -ne "Disconnected" -and $_.DNSServer -ne $null } 

	# Display the VPN DNS servers
	if ($VpnNetworkConfigurations) {
		# Get the DNS server addresses for the VPN network interface
		$VpnDnsServers = Get-DnsClientServerAddress -InterfaceAlias $VpnNetworkConfigurations.InterfaceAlias
		# Do not take into account IPv6 site-local address range (fec0::/10)
		$pattern = "^fec0"
		$hasMatch = $false
		foreach ($address in $VpnDnsServers.ServerAddresses) {
			if ($address -match $pattern) {	
				$hasMatch = $true
				break
			}
		}	
		if (!$hasMatch) {
			Write-Host -ForegroundColor RED "`n !!! If you are using a VPN, you might not be using the above default DNS servers !!!"
			Write-Host -ForegroundColor Green "`n VPN DNS Servers: $($VpnDnsServers.ServerAddresses)"
		}
	}
}

function Get-DomainNameFromUrl {
    param (
        [string]$url
    )

    # Use the Uri class to parse the URL
    $uri = New-Object System.Uri($url)

    # Extract the host (domain name)
    $domain = $uri.Host

    # Return the domain name
    return $domain
}

function Get-DomainNameStatus {
# Print each item in the url_list
	foreach ($item in $url_list) {
		Write-Host -ForegroundColor Yellow " $item " -NoNewline 
		Write-Host "  DNS:" -NoNewline	
		try {
			$dnsInfo = Resolve-DnsName (Get-DomainNameFromUrl -url $item) -ErrorAction Stop
			Write-Host -ForegroundColor Green "OK"
		} catch {
			Write-Host -ForegroundColor Red "Failed"
			}
	}
}
	
### main ###

Get-Dns
Get-DomainNameStatus
