# ===============================================================================
# ===========================| ITNCM Script Ver. 2.1 |===========================
#
#                   Target Platform: Windows Server 2008-12/16 R2
#
# ===============================================================================

function get_software($path){
    
    $output_array = @()

    foreach($item in $path){
            $properties = @{
                DisplayName = $item.DisplayName
                DisplayVersion = $item.DisplayVersion | Where-Object {$_.DisplayVersion -ne '1' -and $_.DisplayVersion -ne '2' -and $_.DisplayVersion -ne $null}
                InstallDate = $item.InstallDate
                Publisher = $item.Publisher 
            }
        if(($item.DisplayName -eq $null) -and ($item.DisplayVersion -eq $null) -and ($item.InstallDate -eq $null) -and ($item.Publisher -eq $null)){
            continue
        }
        else{
            $new_obj = New-Object -TypeName PSObject -Property $properties
            $output_array += $new_obj
        }
    }
    return $output_array
}

function write_32($output){
    foreach($o in $output){
        if($o.Publisher -eq $null){
            write-output("C010_2_R1:1:3,$hostname,$($o.Displayname.ToUpper()),$($o.DisplayVersion),$($o.InstallDate),$($o.Publisher), 32-bit")
        }
            else{
            write-output("C010_2_R1:1:3,$hostname,$($o.Displayname.ToUpper()),$($o.DisplayVersion),$($o.InstallDate),$($o.Publisher.Trim(".") -Replace ","," "), 32-bit")
        }
    }
}

function write_64($output){
    foreach($o in $output){
        if($o.Publisher -eq $null){
            write-output("C010_2_R1:1:3,$hostname,$($o.Displayname.ToUpper()),$($o.DisplayVersion),$($o.InstallDate),$($o.Publisher), 64-bit")
        }
            else{
            write-output("C010_2_R1:1:3,$hostname,$($o.Displayname.ToUpper()),$($o.DisplayVersion),$($o.InstallDate),$($o.Publisher.Trim(".") -Replace ","," "), 64-bit")
        }
    }
}
function get_network_properties($network_config){
    $output_array = @()

    foreach($item in $network_config){
        $properties = @{
            HostName = $item.DNSHostName
            IPAddress = $item.IPAddress
            MacAddress = $item.MACAddress
        }
        $new_obj = New-Object -TypeName PSObject -Property $properties
        $output_array += $new_obj
    }
    foreach($o in $output_array){
        write-output("HOST:IP:MAC,$($o.HostName),$($o.IPAddress),$($o.MacAddress)`n")

    }
}
function get_netstat_processes($netstat_command){    
    $ipv4_array = @()
    $ipv6_array = @()    
    foreach($line in $netstat_command){    
        if((($line -match "[::]") -or ($line -match "[::1]")) -and ($line -match "TCP")){
            $line = $line -replace '^\s+', '' -split '\s+'            
            $properties = @{
                Protocol = $line[0]
                LocalPort = ($line[1] -split ":")[3]
                State = $line[3]
                PID = $line[4]
            }      
            $obj = New-Object -TypeName PSObject -Property $properties
            $ipv6_array += $obj     
        }
        else{continue}
    }
    foreach($line in $netstat_command){ 
        if($line -match "TCP"){
            $line = $line -replace '^\s+', '' -split '\s+'            
            $properties = @{
                Protocol = $line[0]
                LocalPort = ($line[1] -split ":")[1]
                State = $line[3]
                PID = $line[4]
            }
            $obj = New-Object -TypeName PSObject -Property $properties
            $ipv4_array += $obj  
        }
        else {continue}
    }
    foreach($line in $ipv4_array){
        if(($line.State -match "LISTENING") -and ($line.LocalPort -ne "")){
            $process_name = $processes | Where {$_.Id -eq $line.PID} | Select -ExpandProperty "ProcessName"
            write-output("C010_2_R1:1:4,$hostname,$($line.Protocol),$($line.LocalPort),$process_name")
        }
    }
    foreach($line in $ipv6_array){
        if(($line.State -match "LISTENING") -and ($line.LocalPort -ne $null)){
            $process_name = $processes | Where {$_.Id -eq $line.PID} | Select -ExpandProperty "ProcessName"
            write-output("C010_2_R1:1:4,$hostname,$($line.Protocol),$($line.LocalPort),$process_name")
        }
    }    
}
function get_netstat_UDP($netstat_command){    
    $output_array = @()    
    foreach($line in $netstat_command){    
        if($line -match "UDP"){
            $line = $line -replace '^\s+', '' -split '\s+'            
            $properties = @{
                Protocol = $line[0]
                LocalPort = ($line[1] -split ":")[1]
                State = $line[3]
                PID = $line[4]
            }      
            $obj = New-Object -TypeName PSObject -Property $properties
            $output_array += $obj     
        }
        else {continue}
    }
    foreach($line in $output_array){
        if($line.LocalPort -eq ''){continue}
        else{
            $process_name = $processes | Where {$_.Id -eq $line.PID} | Select -ExpandProperty "ProcessName"
            write-output("C010_2_R1:1:4,$hostname,$($line.Protocol),$($line.LocalPort)")
        }
    }
    write-output("")
}
function get_hotfix($data){
    $output_array = @()

    foreach($line in $hot_fix){
        $properties = @{
            HotFixID = $line.HotfixID | Where-Object {$_.HotFixID -ne 'File 1'}
            Description = $line.Description
            InstalledOn = $line.InstalledOn
        }
        $new_obj = New-Object -TypeName PSObject -Property $properties
        $output_array += $new_obj
    }

    write-output("C010_2_R1:1:5,hotfix_id,description,installed_date")
    foreach($o in $output_array){
        write-output("C010_2_R1:1:5,$hostname,$($o.HotFixID),$($o.Description),$($o.InstalledOn)")
    }
    write-output("")
}

#===========================| Host Address Information |=========================
#================================================================================

write-output("### HOST_ADDRESS_INFO_START ###`n")
$network = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName .
write-output("hostname,ip_address,mac_address")
get_network_properties($network)
write-output("### HOST_ADDRESS_INFO_END ###`n")

#==================================| CIP 07__1 |=================================
#================================================================================

write-output("### C007_6_R1:1__START ###")
write-output("### C010_2_R1:1:4__START ###")
write-output("###__Ports and Services that are enabled or listening on the system ###`n")

$netstat = netstat -aon
$processes = Get-Process
$hostname = hostname

get_netstat_processes($netstat)
get_netstat_UDP($netstat)
write-output("### C010_2_R1:1:4__END ###")
write-output("### C007_6_R1:1__END ###`n")

#==================================| CIP 07__2 |=================================
#================================================================================

write-output("### C007_6_R2:3__START ###")
write-output("### C010_2_R1:1:5__START ###")
write-output("###__Any Security Patches applied ###`n")

$hot_fix = Get-HotFix

get_hotfix($hot_fix)
write-output("### C010_2_R1:1:5__END ###")
write-output("### C010_2_R1:1:5__END ###`n")

#==================================| CIP 07__3 |=================================
#================================================================================

write-output("### C007_6_R3:1__START ###")
write-output("###__Check if device has AV installed ###")
write-output("###__________Not Capable__________###")
write-output("### C007_6_R3:1__END ###`n")

#==================================| CIP 07__4 |=================================
#================================================================================

write-output("### C007_6_R5:1__START ###")
write-output("###__Check to ensure that authentication methods are enabled ###")
write-output("###__pointing to appropriate server ###`n")

$host_domain = (get-WMIObject WIN32_ComputerSystem).Domain

write-output("C007_6_R5:1, domain")
write-output("C007_6_R5:1, $($host_domain)")
write-output("### CIP:007_6_R5:1__END ###`n")

#==================================| CIP 07__5 |=================================
#================================================================================

write-output("### C007_6_R5:7__START ###")
write-output("###__Check for Account lockout enabled for a specified threshold ###")
write-output("###__Check to ensure that logging is enabled and sending data to the correct collectors ###`n")

# TODO
net accounts

write-output("### C007_6_R5:7__END ###`n")

#==================================| CIP 07__7 |=================================
#================================================================================

write-output("### C007_6_R5:2__START ###")
write-output("###__Detect any default or generic account and report it ###`n")

# TODO
Foreach ($U In Get-WmiObject -Class Win32_UserAccount -Namespace "root/cimv2" -Filter "LocalAccount=TRUE AND Disabled=FALSE") {net user $U.Name}

write-output("### C007_6_R5:2__END ###`n")

#==================================| CIP 07__8 |=================================
#================================================================================

write-output("### C007_6_R5:4__START ###")
write-output("###__Check for any default passwords ###`n")
write-output("### C007_6_R5:4__END ###`n")

#==================================| CIP 07__9 |=================================
#================================================================================

write-output("### C007_6_R5:5:1__START ###")
write-output("###__Check Password complexity to meet 8 characters in length ###")
write-output("### C007_6_R5:5:2__START ###")
write-output("###__Check password that upper case lowercase numeric and non numeric characters are enforced ###`n")

write-output("### C007_6_R5:5:2__END ###")
write-output("### C007_6_R5:5:1__END ###`n")

#==================================| CIP 07__10 |================================
#================================================================================

write-output("### C007_6_R5:6__START ###")
write-output("###__Check for user account password not changed within 15 calendar months ###`n")

write-output("### C007_6_R5:6__END ###`n")

#==================================| CIP 010__1 |================================
#================================================================================

write-output("### C010_2_R1:1:1__START ###")
write-output("###__Operating system or firmware including version ###`n")

# gwmi Win32_OperatingSystem |select caption, installdate, OSArchitecture, version, BuildNumber, servicepackmajorversion | Format-List | Out-String
$os_info = gwmi Win32_OperatingSystem | select caption, installdate, OSArchitecture, version, BuildNumber, servicepackmajorversion

write-output("C010_2_R1:1:1,hostname,os_caption,install_date,os_architecture,os_version,os_build_number,service_pack_version")
write-output("C010_2_R1:1:1, $hostname, $($os_info.caption), $($os_info.installdate), $($os_info.OSArchitecture), $($os_info.version), $($os_info.BuildNumber), $($os_info.servicepackmajorversion)")
write-output("### C010_2_R1:1:1__END ###`n")

#==================================| CIP 010__2 |================================
#================================================================================

write-output("### C010_2_R1:1:2__START ###")
write-output("###__Any commercially available or open_source application software installed including version ###`n")

# if(1) {Get-ChildItem HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\ | ForEach-object {Get-ItemProperty $_.pspath} | Select-Object @{Label="DisplayName";Expression={$_.DisplayName.ToUpper()}}, DisplayVersion, InstallDate, Publisher | Where-Object {$_.DisplayVersion -ne '1' -and $_.DisplayVersion -ne '2' -and $_.DisplayVersion -ne $null} | Sort-Object -property DisplayName | Format-Table -Wrap | Out-String }

write-output("### C010_2_R1:1:2__END ###`n")

#==================================| CIP 010__3 |================================
#================================================================================

write-output("### C010_2_R1:1:3__START ###")
write-output("###__Any custom software installed ###`n")

$32_bit_reg_path = Get-ItemProperty HKLM:\\Software\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*
$64_bit_reg_path = Get-ItemProperty HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*

write-output("C010_2_R1:1:3,hostname,display_name,display_version,install_date,publisher,sw_type")

$32_bit_apps = get_software($32_bit_reg_path)
$64_bit_apps = get_software($64_bit_reg_path)
write_32($32_bit_apps)
write_64($64_bit_apps)

write-output("### C010_2_R1:1:3__END ###`n")

#==================================| CIP 010__4 |================================
#================================================================================

write-output("### C010_2_R1:1:4__START ###")
write-output("###__Any logical network accessible ports ###")
write-output("###___SEE C007_6_R1:1___###`n")

write-output("### C010_2_R1:1:4__END ###`n")

#==================================| CIP 010__5 |================================
#================================================================================

write-output("### C010_2_R1:1:5__START ###")
write-output("###__Any security patches installed ###")
write-output("###___SEE  C007_6_R2:3___###`n")
write-output("### C010_5_R1:1:5__END ###`n")

#================================================================================
write-output("### END OF SCRIPT ###`n`r")
#================================================================================

Return



