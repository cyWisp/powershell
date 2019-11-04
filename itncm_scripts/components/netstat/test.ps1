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
    write-output("")    
}

write-output("C010_2_R1:1:4,hostname,protocol,port,process_name")

$netstat = netstat -aon
$processes = Get-Process
$hostname = hostname

get_netstat_processes($netstat)