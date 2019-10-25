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
        write-output("C010_2_R1:1:3,$hostname,$($o.Displayname.ToUpper()),$($o.DisplayVersion),$($o.InstallDate),$($o.Publisher.Trim(".") -Replace ","," "),32-bit")
    }
}

function write_64($output){
    foreach($o in $output){
        write-output("C010_2_R1:1:3,$hostname,$($o.Displayname.ToUpper()),$($o.DisplayVersion),$($o.InstallDate),$($o.Publisher.Trim(".") -Replace ","," "),64-bit")
    }
    write-output("")
}

$hostname = hostname
$32_bit_reg_path = Get-ItemProperty HKLM:\\Software\\Wow6432Node\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*
$64_bit_reg_path = Get-ItemProperty HKLM:\\Software\\Microsoft\\Windows\\CurrentVersion\\Uninstall\\*

$32_bit_apps = get_software($32_bit_reg_path)
$64_bit_apps = get_software($64_bit_reg_path)
write_32($32_bit_apps)
write_64($64_bit_apps)