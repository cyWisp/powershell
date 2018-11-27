$user = "prem@usmed.com"
$groups = Get-DistributionGroup
$DGs = $groups | where-object { ( Get-DistributionGroupMember $_ | where-object { $_.PrimarySmtpAddress -contains $user}) } 

foreach( $dg in $DGs){
	Remove-DistributionGroupMember $dg -Member $user
}