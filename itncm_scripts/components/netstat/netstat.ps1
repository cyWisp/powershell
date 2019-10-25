function get_netstat_processes($netstat_command){    
    $output_array = @()    
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
            if($obj.LocalPort){
                $output_array += $obj
            }
            else {continue}
        }
        else {continue}
    }
    write-output("C010_2_R1:1:4,hostname,protocol,port,process_name")
    foreach($line in $output_array){
        $process_name = $processes | Where {$_.Id -eq $line.PID} | Select -ExpandProperty "ProcessName"
        write-output("C010_2_R1:1:4,$hostname,$($line.Protocol),$($line.LocalPort),$process_name")
    }
    write-output("")
}

$netstat = netstat -aon
$processes = Get-Process
$hostname = hostname

get_netstat_processes($netstat)

