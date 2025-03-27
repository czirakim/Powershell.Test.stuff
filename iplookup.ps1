# Print the header
Write-Host -ForegroundColor Green "`n##############################################################################################"
Write-Host -ForegroundColor Green "# This tool is designed to determine the site associated with a given IP address.            #"
Write-Host -ForegroundColor Green "##############################################################################################"
# The rest of your script goes here

# Create a list of custom objects
$list = @()

# Function to check the second octet
function Check-Octet {
    
    param (
        [string]$targetOctets
    )

    # Path to the CSV file
    $csvFilePath = "destination.csv"
    # Import the CSV file
    $data = Import-Csv -Path $csvFilePath 
    
    $count = 0
    
    foreach ($row in $data) { 
        # Split the IP address into its octets
        $octets = $row.IPAddress -split '\.'
        # Check if the first 3 octets matche the target value
        if ("$($octets[0]).$($octets[1]).$($octets[2])" -eq $targetOctets) {
            Write-Host -ForegroundColor Yellow "`n Location: " $row.Name
            $count = 0
            break
        }
        else {
            $count += 1
        }
    }
    if ( $count -ne 0 ) {
        Write-Host -ForegroundColor Yellow "`n Location: unknown" 
    }
}
# Call the function with the target second octet value
function check_ip{

    param (
    [string]$ipAddress
    )

    Write-Host -ForegroundColor Yellow "`n IP address: $ipAddress" $item.Name
    
    if ([System.Net.IPAddress]::TryParse($ipAddress, [ref]$null)) {
        $octets = $ipAddress -split '\.'
        Check-Octet -targetOctet "$($octets[0]).$($octets[1]).$($octets[2])"
    }else{
        Write-Host -ForegroundColor Red "`n Invalid IP Address"
    }    
    
    Write-Host -ForegroundColor Yellow "`n"  
}

### main ###

check_ip ($args[0])
