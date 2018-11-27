$Date = Get-Date -Format ddMMyyyy 
$Computer = "$ENV:COMPUTERNAME" | %{ 
  $Computer = $_ 
  Get-WMIObject Win32_NTEventLogFile -Computername $Computer -Filter "LogfileName='Application' OR LogfileName='Security' OR LogfileName='System'" | %{$_.PSBase.Scope.Options.EnablePrivileges = $True;
    
    $Location = "\\ServerName\Logs\$Computer"
    if (!(test-Path $Location)) {
    md $Location
    } 
    # Save it 
    $_.BackupEventLog("\\ServerName\Logs\$Computer\$($_.LogFileName) - $(Get-Date -f MM-dd-yyyy-hhmmtt).evt") 
    # Clear it 
    $_.ClearEventLog() 
	} 
	}