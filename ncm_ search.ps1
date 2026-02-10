#This is a script for searching in the Solarwinds NCM config files via Rest API
#
# CLI searchTerm parameter

param(
    [Parameter (Position=0, Mandatory=$true)]
    [string]$searchTerm,
    [Parameter (Position=1, Mandatory=$false)]
    [string]$days=7
    )
# Load var file
$configFile = Join-Path $HOME ".env.ps1"
.$configFile

#skip cert validation
[System.Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

# Get credentials
$hostname = $env:SOLARWINDS_HOST
$username = $env:SOLARWINDS_USER
$password = $env:SOLARWINDS_PASS

#Auth
$base64AuthInfo = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(("{0}:{1}" -f $username, $password)))

$headers = @{
    "Authorization" = "Basic $base64AuthInfo"
    "Content-Type" = "application/json"
}
$base_uri = "https://" + $hostname + ":17774/SolarWinds/InformationService/v3/Json/Query"

$query = @{
    query = "SELECT 
OrionNodes.Caption AS DeviceName,
NcmArchive.ConfigType,
NcmArchive.DownloadTime,
NcmArchive.Config
FROM  NCM.ConfigArchive AS NcmArchive
INNER JOIN NCM.Nodes AS NcmNodes ON NcmArchive.NodeID = NcmNodes.NodeID
INNER JOIN Orion.Nodes AS OrionNodes ON NcmNodes.CoreNodeID = OrionNodes.NodeID
WHERE NcmArchive.Config LIKE '%$searchTerm%'
AND NcmArchive.ConfigType = 'Running'
AND NcmArchive.DownloadTime > ADDDAY(-$days, GETUTCDATE())
ORDER BY NcmArchive.DownloadTime DESC"
}

$uri = $base_uri

$body = $query | ConvertTo-Json -Compress

try {
    $response = Invoke-RestMethod -Uri $uri -Method Post -Headers $headers -Body $body -UseBasicParsing
} catch { 
        Write-Host "Status Code: $($_.Exception.Response.StatusCode.value)" -ForegroundColor Yellow
        Write-Host "Status Description: $($_.Exception.Response.StatusDescription)" -ForegroundColor Yellow
        Write-Host "Status Message: $($_.Exception.ToString())" -ForegroundColor Yellow
}

if ($null -eq $response.results -or $response.results.Count -eq 0) {
    Write-Warning "The SQL query returned no results from SolarWinds."
    return # Stop the script here 
}
<#
$uniqueResults = $response.results | 
    Group-Object DeviceName |
    ForEach-Object
    {
        # Sort each group by date and pick the first (newest) one
        $_.Group | Sort-Object DownloadTime -Descending | Select-Object -First 1
    }
#>
$finalResults = $response.results |
    # Exclude any DeviceName containing 'Standby' (case-insensitive)
    Where-Object { $_.DeviceName -notlike "*Standby*" } |
    # Group by DeviceName to remove duplicates
    Group-Object DeviceName |
    ForEach-Object {
        # Pick the newest config for each unique device
        $_.Group | Sort-Object DownloadTime -Descending | Select-Object -First 1
    }

Write-Host "`nFound in $($finalResults.results.Count) config files." -ForegroundColor Green
$finalResults | Format-Table -AutoSize

$report = foreach ($entry in $finalResults) {
    # Split the config into lines and find the match
    $matchingLines = $entry.Config -split "`r`n" | Select-String -Pattern $searchTerm

    if ($matchingLines) {
        [PSCustomObject]@{
            DeviceName = $entry.DeviceName
            Matches = $matchingLines.Line -join "; "
        }
    }
}

Write-Host "`nMatches found." -ForegroundColor Green
$report | Format-Table -AutoSize
