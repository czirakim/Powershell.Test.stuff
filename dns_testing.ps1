$url_list = @("http://acme.com",
              "http://google.com" 
		  )


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
	
Get-DomainNameStatus