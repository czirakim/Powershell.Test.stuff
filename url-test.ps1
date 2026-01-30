$list_repsonse - @( "000", $null)
$san - @()

# Path to the file
$FilePath = "destinations-url.txt"
# Import the file 
$data Get-Content -Path $FilePath

function Test_url {
    # Print each item in the url_list 
    #Write-Host "`n Testing URLS: `n" 
    foreach ($item in $data) {
        Write-Host " $item " -NoNewline -ForegroundColor Yellow
        Write-Host " StatusCode: " -NoNewline
        $request = [System.Net.HttpWebRequest]::Create($item)
        $request.Timeout 10000
        $request.AllowAutoredirect = $true
        $request.KeepAlive $false
        
        # below the version using the native PowerShell command 
        try {
            $response = $request.GetResponse()
            $statusCode = $response. StatusCode.value__
            $response.Close()
            } catch {
                # If there was an error, get the status code from the exception. 
                $statusCode = $_.Exception.Response. StatusCode.value__
            }
            
            Scert = New-Object Security.Cryptography.X509Certificates.X509Certificate2($request.ServicePoint.Certificate)
            [void]$request.ServicePoint.CloseConnectionGroup("")
            
            if ($list_repsonse -notcontains $statusCode) {
                Write-Host-ForegroundColor Green $statusCode
            } else {
                Write-Host-ForegroundColor Red $statusCode
            }
        cert_info
        Start-Sleep -Milliseconds 500
    }
}

function cert_info {
    $san = ($cert.Extensions | Where-Object{$_.Oid.FriendlyName -eq "Subject Alternative Name"}).Format($false) -split ', ' | Where-Object {$_ -match '^DNS Name='} | ForEach-Object{$_ -replace 'DNS Name=',''}

    Write-Host "`n === SSL Certificate info---" -ForegroundColor Magenta
    Write-Host "$($cert.Subject)"
    Write-Host "$($cert.Issuer)"
    Write-Host "`n Alternative DNS names:" -ForegroundColor Magenta
    $san | ForEach-Object { Write-Host " - $_"}
    Write-Host "`n Issued/expiration Date:" -ForegroundColor Magenta
    Write-Host "$($cert.NotBefore.ToString('yyy-MM-dd'))"
    Write-Host "$($cert.NotAfter.ToString('yyy-MM-dd'))"
    Write-Host "`n Days to Expire:" -ForegroundColor Magenta
    $days = ($cert.NotAfter - (Get-Date)).Days
    if ($days -lt 0) { Write-Host" EXPIRED!!!" -ForegroundColor Red }
    elseif ($days -lt 30){
        Write-Host "$days days WARNING!" -ForegroundColor Yellow
        }
    else {
        Write-Host "$days days" -ForegroundColor Green
    }
    Write-Host ""
}
    

### main ###
Write-Host -ForegroundColor Green "`n Url tests ... `n"

Test_url

Write-Host -ForegroundColor Green "`n tests DONE... "
