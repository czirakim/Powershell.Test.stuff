#This Script can be used for testing access to different addresses using different protocols
#
#

# Create some lists (array) of items
$url_list = @("http://acme.com",
              "http://google.com" 
          		  		)


$share_list = @("fileshare1",
               "fileshare2"
			   )

$rdp_list = @( "192.168.1.10",
	 	"192.168.1.11"
			)
			
$ssh_list = @( "192.168.1.12"			
			)			

$list_repsonse = @( "000" , $null)

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
    param (
        [string]$url = $null,
        [string]$domainName = $null
    )

    Write-Host "  DNS:" -NoNewline

    try {
        if ($url) {
            $domainName = Get-DomainNameFromUrl -url $url
        }
        
        $dnsInfo = Resolve-DnsName $domainName -ErrorAction Stop
        Write-Host -ForegroundColor Green "OK"
    } catch {
        Write-Host -ForegroundColor Red "Failed"
    }
}

function Test_url {
# Print each item in the url_list
	Write-Host "`n Testing URLs: `n"
	
	foreach ($item in $url_list) {
		Write-Host " $item " -NoNewline	-ForegroundColor Yellow
		Write-Host "  StatusCode: " -NoNewline
 
		#$response = . curl -sk -m 10 -o /dev/null -w "%{http_code}" $item
                # below the version without curl, using the native PowerShell command
		try {
            	$response = Invoke-WebRequest -Uri $item -TimeoutSec 10 -ErrorAction Stop
            	$statusCode = $response.StatusCode
       	 	} catch {
        	# If there was an error, get the status code from the exception
            	$statusCode = $_.Exception.Response.StatusCode.value__
        	}  
        	if ($list_repsonse -notcontains $statusCode ) {
            	Write-Host -ForegroundColor Green $statusCode -NoNewline
        	} else {
            	Write-Host -ForegroundColor Red "Failed" -NoNewline
        	}
        	Get-DomainNameStatus -url $item
		}
}
	
function Test_share {
# Print each item in the Share_list
	Write-Host "`n`n Testing Share Paths: `n"
	
	foreach ($item in $share_list) {
		Write-Host " $item " -NoNewline -ForegroundColor Yellow
	
		$response = Test-NetConnection  -ComputerName $item -CommonTCPPort SMB -InformationLevel "Quiet"

		if ($response) {
			Write-Host -ForegroundColor Green "OK" -NoNewline	
		} else {
			Write-Host -ForegroundColor Red "Failed" -NoNewline	
		}
		
		Get-DomainNameStatus -domainName $item
	}	
}

function Test_rdp  {
# Print each item in the rdp_list
	Write-Host "`n`n Testing RDP: `n"
	
	foreach ($item in $rdp_list) {
		Write-Host " $item " -NoNewline -ForegroundColor Yellow
	
		$response = Test-NetConnection  -ComputerName $item -CommonTCPPort RDP -InformationLevel "Quiet"
		
		if ($response) {
			Write-Host -ForegroundColor Green "OK" -NoNewline	
		} else {
			Write-Host -ForegroundColor Red "Failed" -NoNewline	
		}
	
		Get-DomainNameStatus -domainName $item
	}
}

function Test_ssh  {
# Print each item in the ssh_list
	Write-Host "`n`n Testing ssh: `n"
	
	foreach ($item in $ssh_list) {
		Write-Host " $item " -NoNewline -ForegroundColor Yellow
		
		$response = Test-NetConnection  -ComputerName $item -Port 22 -InformationLevel "Quiet"
	
		if ($response) {
			Write-Host -ForegroundColor Green "OK" -NoNewline	
		} else {
			Write-Host -ForegroundColor Red "Failed" -NoNewline	
		}
	
		Get-DomainNameStatus -domainName $item
	}
}

### main ###

Write-Host -ForegroundColor Green "`n Starting tests ... "
Get-Dns
Test_url
Test_share
Test_rdp
Test_ssh
