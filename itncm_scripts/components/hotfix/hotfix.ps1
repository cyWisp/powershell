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

$hot_fix = Get-HotFix
get_hotfix($hot_fix)