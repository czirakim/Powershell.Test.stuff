# Create a list of custom objects
$list = @()

# Path to the CSV file
$csvFilePath = "source.csv"
$csvPathDestination = "destination.csv"
# Import the CSV file
$data = Import-Csv -Path $csvFilePath 
# replace strings and add to list
foreach ($row in $data) {
    $name = $($row.Type)
    $subnet =  $($row.Subnet)
    #Write-Output $name
    switch -Wildcard ($name) {
        "*dub*"{
            $name = 'Ireland, Dublin'
            $list += [PSCustomObject]@{ Name = $name; IPAddress = $subnet }
        }
        "*osk*"{
            $name = 'Japan, Osaka'
            $list += [PSCustomObject]@{ Name = $name; IPAddress = $subnet }
        }
        "*prs*"{
            $name = 'France, Paris'
            $list += [PSCustomObject]@{ Name = $name; IPAddress = $subnet }
        }    
    }
}

### write output on screen
foreach ($item in $list) {
   Write-Host  $item.Name $item.IPAddress
}
### write in a file
$list | Export-Csv -Path $csvPathDestination -NoTypeInformation
