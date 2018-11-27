$DGs= Get-DistributionGroup | where { (Get-DistributionGroupMember $_ | foreach {$_.PrimarySmtpAddress}) -contains “user@domain.com” }

foreach( $dg in $DGs){

Remove-DistributionGroupMember $dg -Member prem@usmed.com
}