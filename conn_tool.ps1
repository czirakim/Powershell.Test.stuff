# Print the header
Write-Host -ForegroundColor Green "##############################################################################################"
Write-Host -ForegroundColor Green "# This is a Tool for testing access to different destination hosts using different protocols #"
Write-Host -ForegroundColor Green "# The tool can test: rdp, ssh, file-share access                                             #"
Write-Host -ForegroundColor Green "##############################################################################################"
# The rest of your script goes here



### get domain function ###
function Get-DomainNameStatus {
    param (
        [string]$url = $null,
        [string]$domainName = $null
    )

    Write-Host "  DNS: " -NoNewline

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

### test rdp ###
function Test_rdp  {

    param (
        [string]$Name = $null
    )

    Write-Host -ForegroundColor Yellow -NoNewline "`n Testing RDP to host $Name "
    Write-Host -NoNewline " Result: "
    
    $response = Test-NetConnection  -ComputerName $Name -CommonTCPPort RDP -InformationLevel "Quiet" -WarningAction SilentlyContinue
           
    if ($response) {
        Write-Host -ForegroundColor Green "OK" -NoNewline  
    } else {
        Write-Host -ForegroundColor Red "Failed" -NoNewline
    }
    Get-DomainNameStatus -domainName $Name

}

### test ssh ###
function Test_ssh  {

    param (
        [string]$Name = $null
    )

    Write-Host -ForegroundColor Yellow -NoNewline "`n Testing ssh to host $Name"
    Write-Host -NoNewline " Result: "
       
    $response = Test-NetConnection  -ComputerName $Name -Port 22 -InformationLevel "Quiet" -WarningAction SilentlyContinue
       
    if ($response) {
        Write-Host -ForegroundColor Green "OK" -NoNewline  
    } else {
        Write-Host -ForegroundColor Red "Failed" -NoNewline
    }
       
    Get-DomainNameStatus -domainName $Name

}

### test file share ###

function Test_share {
   
    param (
        [string]$Name = $null
    )

    Write-Host -ForegroundColor Yellow -NoNewline "`n Testing Share Paths to host $Name"
    Write-Host -NoNewline " Result: "
       
    $response = Test-NetConnection  -ComputerName $Name -CommonTCPPort SMB -InformationLevel "Quiet" -WarningAction SilentlyContinue
   
    if ($response) {
        Write-Host -ForegroundColor Green "OK" -NoNewline  
        }
    else{
        Write-Host -ForegroundColor Red "Failed" -NoNewline
    }
           
    Get-DomainNameStatus -domainName $Name
   
}

### main function ###
function Get-UserInput {
    # Suppress warnings
    $WarningPreference = "SilentlyContinue"

    # Prompt for name
    $name = Read-Host "`n Please enter what you want to test (RDP,SSH,file-share)"
    switch ($name.Trim()) {
        "rdp" {
            $dest = Read-Host " Please enter destination host you want to test"
            Test_rdp -Name $dest
        }
        "ssh" {
            $dest = Read-Host " Please enter destination host you want to test"
            Test_ssh -Name $dest
        }
        "file-share" {
            $dest = Read-Host " Please enter destination host you want to test"
            Test_share -Name $dest
        }
    }    
}

### main ###

Get-UserInput
