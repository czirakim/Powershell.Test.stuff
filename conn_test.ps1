# Define the server to ping

$server_list = @("dns.google.com",  # Google DNS
                "1.1.1.1" ,         # Cloudflare DNS
		"dns.quad9.net"     # Quad9 DNS 
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
function ping {
# Perform the ping test
$pingResult = Test-Connection -ComputerName $item -Count 4 -ErrorAction SilentlyContinue

# Check if the ping was successful
	if ($pingResult) {
		Write-Output "Internet connectivity test successful. Ping results:"
		$pingResult | ForEach-Object {
			if ($_.IPV4Address) {$_.Address = $_.IPV4Address}
			Write-Output ("Reply from {0}: time={1}ms" -f $_.Address, $_.ResponseTime)
		}
	} else {
		Write-Host -ForegroundColor Red "Failed. Unable to reach $item "
}
}

function test_ping {
	# performing ping tests
	$defaultGateway = Get-NetRoute -DestinationPrefix "0.0.0.0/0" |  Where-Object -FilterScript { $_.NextHop -Ne "0.0.0.0" } |  Select-Object -ExpandProperty "NextHop"
	$updated_List = @($defaultGateway) + $server_list    

	foreach ($item in $updated_List) {
		if ($item -eq $defaultGateway) {
			Write-Host -ForegroundColor Yellow "`n Test for Default gateway ($item):" 
			}			
		else {	
			Write-Host -ForegroundColor Yellow "`n Test for $item :"
			}
		ping
	}
}

### main ###

Write-Host -ForegroundColor Green "`n Connectivity tests ... "

$publicIP = Invoke-RestMethod -Uri "https://api.ipify.org"
Write-Host -ForegroundColor Green "`n Public IP: $publicIP"

Get-Dns
test_ping
