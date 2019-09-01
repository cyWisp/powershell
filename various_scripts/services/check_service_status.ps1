# =======================================================
# Title: check_service_status.ps1
# Author: Robert Daglio
# Version 1.1
# Date: 08_22_2019
# Description: This script will read a list of services
#   to check for, and will query the host machine for 
#   the name, startMode and state of said service and
#   output the information to a text file
# =======================================================

# If output.txt exists, delete it, otherwise continue execution
if (Test-Path "./output.txt"){
    write-host("[!] Deleting output.txt!")
    Remove-Item -Path "./output.txt"
}

#Create empty arrays for iteration and output
$services = @()
$output_array = @()

# Read the contents of "service_list.txt" into said array
foreach($line in Get-Content -Path "./service_list.txt"){
    $services += $line
}

# Iterate through the array checking for services
foreach($item in $services){
    $service = Get-WMIObject win32_service -filter "name='$item'" -computer "."
    if($service){
        # Gather service Information
        $service_name = Write-Output($service.Name)
        $service_start_mode = Write-Output($service.StartMode)
        $service_state = Write-Output($service.State)

        # Print Service Information
        write-host("[*] Service Name: $service_name")
        write-host("[*] Service Start Mode: $service_start_mode")
        write-host("[*] Service State: $service_state")

        $output_array += "[*] Service Name: $service_name"
        $output_array += "[*] Service Start Mode: $service_start_mode"
        $output_array += "[*] Service State: $service_state`n"
    }
    else {
        write-host("[x] $item not found!")
    }
}

$output_file = New-Item -Type file -Path "./output.txt"
foreach($item in $output_array){
    write-output($item) >> "./output.txt"
}

write-host("[*] Done!")


