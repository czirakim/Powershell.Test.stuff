# Define the server to ping

$server_list = @("dns.google.com",  # Google DNS
                "1.1.1.1" ,         # Cloudflare DNS
				"dns.quad9.net"     # Quad9 DNS 
				)

function ping {
# Perform the ping test
$pingResult = Test-Connection -ComputerName $item -Count 4 -ErrorAction SilentlyContinue

# Check if the ping was successful
	if ($pingResult) {
		Write-Output "Internet connectivity test successful. Ping results:"
		$pingResult | ForEach-Object {
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
test_ping

