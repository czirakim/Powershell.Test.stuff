##############################################################################################
# This is a Tool for testing access to different destination hosts using different protocols #
# The tool can test: rdp,ssh,file-share access, TCP port                                     #
# You can also choose multiple tests. Ex:ssh,port                                            #
##############################################################################################


# Print the header
Write-Host -ForegroundColor Green "`n##############################################################################################"
Write-Host -ForegroundColor Green "# This is a Tool for testing access to different destination hosts using different protocols #"
Write-Host -ForegroundColor Green "# The tool can test: rdp, ssh, file-share access, TCP port                                   #"
Write-Host -ForegroundColor Green "# You can also choose multiple tests. Ex:ssh,port                                            #"
Write-Host -ForegroundColor Green "##############################################################################################"
# The rest of your script goes here

# Suppress warnings
$WarningPreference = "SilentlyContinue"

### get domain function ###
function Get-DomainNameStatus {
    param (
        [string]$url = $null,
        [string]$domainName = $null
    )

    Write-Host " DNS: " -NoNewline

    try {
        if ($url) {
            $domainName = Get-DomainNameFromUrl -url $url
        }
        
        $dnsInfo = Resolve-DnsName $domainName -type A -ErrorAction Stop
        Write-Host -NoNewline -ForegroundColor Green "OK"
    } catch {
        Write-Host -NoNewline -ForegroundColor Red "Failed"
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
        	
}
### test custom port ###
function Test_custom_port {
    
    param (
        [string]$port = $null,
        [string]$Name = $null
    )

    Write-Host -ForegroundColor Yellow -NoNewline "`n Testing TCP port $port to host $Name"
    Write-Host -NoNewline " Result: "
        
    $response = Test-NetConnection  -ComputerName $Name -Port $port -InformationLevel "Quiet" -WarningAction SilentlyContinue
    
    if ($response) {
        Write-Host -ForegroundColor Green "OK" -NoNewline	
        }
    else{
        Write-Host -ForegroundColor Red "Failed" -NoNewline
    }
            	
}

### main function ###
function Get-UserInput {
    # Suppress warnings
    $WarningPreference = "SilentlyContinue"

    # Prompt for name
    $name = Read-Host "`n Please enter what you want to test (RDP,SSH,file-share,port)"
    $list = $name.Trim().Split(',')
    $dest = Read-Host " Please enter destination host you want to test"
    if ('port' -in $list) {
        $port = Read-Host " Please enter the TCP port you want to test"
    }
    Write-Host -ForegroundColor Yellow -NoNewline "`n Testing DNS for host $dest"
    Get-DomainNameStatus -domainName $dest
    foreach ($item in $list) {

        switch ($item) {
            "rdp" {
                Test_rdp -Name $dest
            }
            "ssh" {
                Test_ssh -Name $dest
            }
            "file-share" {
                Test_share -Name $dest
            }
            "port"{
                Test_custom_port -Name $dest -port $port
            }
        }
    }
    Write-Host -ForegroundColor Yellow "`n"    
}

### main ###

Get-UserInput
