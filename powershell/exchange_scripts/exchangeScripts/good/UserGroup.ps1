[CmdletBinding(SupportsShouldProcess=$True)]
Param(
	[Parameter(Mandatory = $True)]
	[String]$UserName
)
Import-Module ActiveDirectory
If ($UserName) {
	$UserName = $UserName.ToUpper().Trim()
	$Res = (Get-ADPrincipalGroupMembership $UserName | Measure-Object).Count
	If ($Res -GT 0) {
		Write-Output "`n"
		Write-Output "The User $UserName Is A Member Of The Following Groups:"
		Write-Output "==========================================================="
		Get-ADPrincipalGroupMembership $UserName | Select-Object -Property Name, GroupScope, GroupCategory | Sort-Object -Property Name | FT -A
	}
}