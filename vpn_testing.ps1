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

$list_repsonse = @( "000" )

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
Write-Host "  DNS:" -NoNewline	
# Print each item in the url_list
		try {
			$dnsInfo = Resolve-DnsName (Get-DomainNameFromUrl -url $item) -ErrorAction Stop
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
    $response = . curl -sk -m 10 -o /dev/null -w "%{http_code}" $item
	if ($list_repsonse -notcontains $response) {
		Write-Host -ForegroundColor Green $response -NoNewline
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
	Write-Host "  DNS: " -NoNewline	
	try {
		$dnsInfo = Resolve-DnsName $item -ErrorAction Stop
		Write-Host -ForegroundColor Green "OK" 
	} catch {
		Write-Host -ForegroundColor Red "Failed" 
		}
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
	Write-Host "  DNS: " -NoNewline	
	try {
		$dnsInfo = Resolve-DnsName $item -ErrorAction Stop
		Write-Host -ForegroundColor Green "OK" 
	} catch {
		Write-Host -ForegroundColor Red "Failed" 
		}
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
	Write-Host "  DNS: " -NoNewline	
	try {
		$dnsInfo = Resolve-DnsName $item -ErrorAction Stop
		Write-Host -ForegroundColor Green "OK" 
	} catch {
		Write-Host -ForegroundColor Red "Failed" 
		}
}
}

### main ###

Test_url
Test_share
Test_rdp
Test_ssh
