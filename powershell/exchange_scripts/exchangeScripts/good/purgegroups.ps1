$dg = Get-DistributionGroup
foreach($group in $dg){
    Get-DistributionGroupMember -Identity $group.identity | ?{$_.recipienttype -eq 'UserMailbox'} |
        foreach{
            $mbx = Get-Mailbox $_.alias
            if($_.name -eq $mbx.name -and $mbx.AccountDisabled -eq $true){
                write-host "Removing User:" $_.alias "from group:" $group.identity
                remove-distributiongroupmember -Identity $group.Identity -Member $_.alias -Confirm:$false
                Write-Host "User Successfully Removed"
                    }    
                }
            } 