<#
.SYNOPSIS
    Test URL redirect chain

.DESCRIPTION
    This script tests a URL redirect chain

.EXAMPLE
    .\url-redirect-tests.ps1
#>

$FilePath = "urls.txt"

# Import the file
$url_list = Get-Content -Path $FilePath
$list_response = @("000", $null)

function Test_url {
    # Print each item in the url_list
    Write-Host "`n Testing URLs: `n"

    foreach ($item in $url_list) {
        Write-Host "`n $item" -NoNewline -ForegroundColor Yellow

        $url = $item
        $maxhops = 10
        $hop = 0

        do {
            $client = [System.Net.WebRequest]::Create($url)
            $client.AllowAutoRedirect = $false
            $client.MaximumAutomaticRedirections = 1
            $client.Method = "GET"
            $client.UserAgent = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/144.0.0.0 Safari/537.36 Edg/144.0.0.0"

            $location = $null

            try {
                $response = $client.GetResponse()
            }
            catch [System.Net.WebException] {
                if ($_.Exception.Response) {
                    $response = $_.Exception.Response
                }
                else {
                    Write-Host "Error: $($_.Exception.Message)"
                    break
                }
            }

            $location = $response.Headers.GetValues("Location") | Select-Object -First 1

            Write-Host " StatusCode: " -NoNewline
            Write-Host "$([int]$response.StatusCode)" -NoNewline -ForegroundColor Cyan

            $response.Close()
            $response.Dispose()

            if ($location) {
                Write-Host " --> $location" -NoNewline -ForegroundColor Blue
                $url = $location
            }

            $hop++
            Start-Sleep -Seconds 1

        } while ($location -and $hop -lt $maxhops)
    }
}

### Main ###

Write-Host -ForegroundColor Green "`n URL tests ..."
Test_url
