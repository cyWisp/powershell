<#
The sample scripts are not supported under any Microsoft standard support 
program or service. The sample scripts are provided AS IS without warranty  
of any kind. Microsoft further disclaims all implied warranties including,  
without limitation, any implied warranties of merchantability or of fitness for 
a particular purpose. The entire risk arising out of the use or performance of  
the sample scripts and documentation remains with you. In no event shall 
Microsoft, its authors, or anyone else involved in the creation, production, or 
delivery of the scripts be liable for any damages whatsoever (including, 
without limitation, damages for loss of business profits, business interruption, 
loss of business information, or other pecuniary loss) arising out of the use 
of or inability to use the sample scripts or documentation, even if Microsoft 
has been advised of the possibility of such damages.
#> 
#requires -Version 2
Import-Module ActiveDirectory
function Set-OSCADAccountPassword
{
	<#
		.SYNOPSIS
			The Set-OSCADAccountPassword command will reset password for a large number of users. 
			
		.DESCRIPTION
			The Set-OSCADAccountPassword command will reset password for users in specified OUs, or in a given CSV file. 
			This CSV file contain one or two columns. One is name of users, anouther is password you want to set. 
			If you do not set password, the command will generate a random password for each user. 
			This password contain 10 characters, 7 char are alphanumeric, the rest are NONalphanumeric
		.PARAMETER Path
			Specifies the path of the CSV file.	The CSV file contains user's name and password(optional).
		.PARAMETER OrganizationalUnit
			Specifies the identity of an AD organizational unit object. The parameter accepts following identity formats.
			Name
				Example: TestOU1
			If you want to specify multiple OU, seperate them with comma. Wildcard"*" is allowed.
		.PARAMETER Password
			Specifies a new password value. The parameter only accepts string.
			It will automatically generate a password for each user, if password does not specify.
		.PARAMETER Recurse
			Get users in the specified OUs and its child OUs.
		.PARAMETER CSVPath
			Specifies the path of CSV file. This CSV file will contain all specified user and their new password.
			Default value is "C:\resultxxxxxxxx.csv", "xxxxxxxx" stand for the current date.
				Example: C:\result09042012.csv
			
		.EXAMPLE
			PS C:\> Set-OSCADAccountPassword -path "c:\Userlist.csv"
			
			Description
			-----------
			This command will reset password for all user, list in the given CSV file.
			
		.EXAMPLE
			PS C:\> Set-OSCADAccountPassword -OrganizationalUnit "testou","testou3" -Recurse
			
			Description
			-----------
			This command will reset password for all user in OU "testou","testou3" and their child OUs.
			
		.EXAMPLE
			PS C:\> Set-OSCADAccountPassword -OrganizationalUnit "testou" -Password "P@Ssw0rd" -CSVPath "d:\result.csv"
			
			Description
			-----------
			This command will reset password to "P@Ssw0rd" for all user in OU "testou" and generate the final CSV file to "d:\result.csv".	
		.LINK
			Windows PowerShell Advanced Function
			http://technet.microsoft.com/en-us/library/dd315326.aspx
		.LINK
			Get-ADOrganizationalUnit
			http://technet.microsoft.com/en-us/library/ee617236.aspx
		.LINK
			Get-ADAccountPassword
			http://technet.microsoft.com/en-us/library/ee617261.aspx
		.LINK
			Get-ADUser	
			http://technet.microsoft.com/en-us/library/ee617241.aspx
		.LINK
			Export-Csv
			http://technet.microsoft.com/library/hh849932.aspx
			
	#>
	[CmdletBinding(SupportsShouldProcess=$true,
					ConfirmImpact="High",
					DefaultParameterSetName="OU")]
	param
	(
		[Parameter(Mandatory=$true,Position=0,ParameterSetName="Path")]
		[String]$Path,
		[Parameter(Mandatory=$True,Position=0,ParameterSetName="OU")]
		[String[]]$OrganizationalUnit,
		[Parameter(Mandatory=$false,Position=1,ParameterSetName="OU")]
		[String]$Password,
		[Parameter(Mandatory=$false,Position=2,ParameterSetName="OU")]
		[switch]$Recurse,
		[Parameter(Mandatory=$false,Position=3)]
		[String]$CSVPath="C:\Result$(Get-Date -Format "MMddyyyy").csv"
	)
	process
	{
		Add-Type -Assembly System.Web
		$result=@()	
		$OUList=@() 
		$UserList=@()
		if ($Pscmdlet.ParameterSetName -eq "Path")
		{
			if (Test-Path $Path)
			{
				$UserList=Import-Csv $path
				$ProgressTitle="Reset password for users specified in $path"
			}
			else
			{
				$errorMsg="Could not find '$path'. Please make sure the path is correct."
				Write-Error -Message $errorMsg
				return
			}
		}
		else
		{
			foreach ($OU in $OrganizationalUnit)
			{
				$OUList+=Get-ADOrganizationalUnit -Filter 'name -like $OU'
			}
			$OUList|select Name,DistinguishedName
			if ($Recurse)
			{
				$SearchScope="Subtree"
				Write-Host "Users' passwords, in these OUs and their sub-ous, will be reset."
				$DNList+=$OUList|ForEach-Object {$_.distinguishedname}
				#Remove duplicate child OU , if exists.
				foreach ($TempOU in $OUList)
				{
					foreach ($DN in $DNList)
					{
						if ($TempOU.DistinguishedName -like "*?$DN")
						{
							$OUList= $OUList -notmatch $TempOU
							#write-verbose
							$verboseMsg = "Duplicate OU:$TempOU is a child OU of $DN."
							Write-Verbose -Message $verboseMsg
							break
						}
					}
				}
			}
			else
			{
				$SearchScope="Onelevel"
				Write-Host "Users' passwords, in these OUs above, will be reset."
			}
			foreach ($TempOU in $OUList)
			{
				$UserList+=Get-Aduser -Filter 'enabled -eq $true' -ResultSetSize $null -SearchBase $TempOU -SearchScope $SearchScope -Properties samaccountname
			}
			$ProgressTitle="Reset password for users in given OUs"
		}
		if($PSCmdlet.ShouldProcess("these users"))
		{
			foreach ($user in $UserList)
			{
				$Identity=$user.SamAccountName
				if ([System.String]::IsNullOrEmpty($Password))
				{
					if ([System.String]::IsNullOrEmpty($user.Password))
					{
						#generate a password with 10 character
						$NewPassword=[Web.Security.Membership]::GeneratePassword(10,3)
					}
					else
					{	
						$NewPassword=$user.Password
					}
				}
				else
				{
					$NewPassword=$Password
				}
				#write progress
				$Counter++
				Write-Progress -Activity $ProgressTitle -Status "Processing" -CurrentOperation $Identity -PercentComplete ($counter / ($Userlist.Count) * 100)
				#reset password
				Set-AdaccountPassword -Identity $Identity -Reset -NewPassword (ConvertTo-SecureString -AsPlainText $NewPassword -Force)
				#export a csv file 
				$Account = New-Object PSObject
				$Account | Add-Member -MemberType NoteProperty -Name "Identity" -Value $Identity
				$Account | Add-Member -MemberType NoteProperty -Name "NewPassword" -Value $NewPassword
				$result+=$Account
			}
			$result|Export-Csv -Path $CSVPath -NoTypeInformation -Force
		}
	} 
}