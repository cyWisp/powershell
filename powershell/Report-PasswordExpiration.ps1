<# Report-PasswordExpiration.ps1

.SYNOPSIS
	Create a CSV and HTML Report on Expiring Passwords
.DESCRIPTION
	This script will create a Password Expiration report.  It creates it in 2 formats,
	CSV and HTML.  Both are then emailed to the specified user.
	
	Make sure to edit and change the PARAM section to match your environment
.PARAMETER From
	Tell the script who the script is coming "from".
.PARAMETER To
	Tell the script where to send the email
.PARAMETER SMTPServer
	This needs to be the IP address or name of your SMTP relay server.
.OUTPUTS
	CSV:	ExpirationReport.csv in the $Path location
	Email:	HTML version of the same report in the body of the email.  Also attaches
			the CSV to the email.
.EXAMPLE
	.\Report-PasswordExpiration.ps1
	Accepts all defaults as defined in the PARAM section
.EXAMPLE
	.\Report-PasswordExpiration.ps1 -Path d:\myreports -From script@yourdomain.com -To Administrator@yourdomain.com -SMTPServer 192.168.1.25
	Runs the report using D:\myreports as the path to save the CSV report.  Email will be sent
	from "script@yourdomain.com" and sent to "Administrator@yourdomain.com" using 192.168.1.25
	as the SMTP relay server.
.NOTES
	Script:				Report-PasswordExpiration.ps1
	Author:				Martin Pugh
	Function Author:	M. Ali
	Webpage:			www.thesurlyadmin.com
	Twitter:			@thesurlyadm1n
	Spiceworks:			Martin9700
	
	Changelog
        1.01            Added loading of RSAT tools (if they're installed)
		1.0				Initial Version
.LINK
	Blog:				www.thesurlyadmin.com
	Original Source code:		https://community.spiceworks.com/scripts/show/1679-password-expiration-report
    Modified Source: 
#>

Param (
	[string]$From = "PasswordExpirationNotice@$($env:Computername).$($env:UserDNSDomain)",
	[string]$To = "adminemail@mycompany.com",
	[string]$SMTPServer = "smtp",
    $ou = @("cn=users,dc=mycompany,dc=com","ou=SecondPlaceToLook,dc=mycompany,dc=com"),
    [datetime]$ExpiresBefore = (get-date).adddays(14)
)

Function Get-XADUserPasswordExpirationDate() {
	# Function written by M.Ali
	# http://blogs.msdn.com/b/adpowershell/archive/2010/02/26/find-out-when-your-password-expires.aspx
	# Modified by Martin Pugh
    # Modifed 26 Jun 2015 by Justin Grote
    Param (
		[Parameter(Mandatory=$true,  Position=0,  ValueFromPipeline=$true, HelpMessage="Identity of the Account")]
		[Object] $accountObj
	)    

    PROCESS {
        If ($accountObj.PasswordExpired) 
		{	Return "Expired"
        } 
		Else 
		{	If ($accountObj.PasswordNeverExpires) 
			{	Return "Password set to never expire"
            } 
			Else 
			{	$passwordSetDate = $accountObj.PasswordLastSet
                If ($passwordSetDate -eq $null) 
				{	Return "Password has never been set"
                }  
				Else 
				{	$maxPasswordAgeTimeSpan = $null
                    $dfl = (get-addomain).DomainMode
                    If ($dfl -ge 3) 
					{	## Greater than Windows2008 domain functional level
                        $accountFGPP = Get-ADUserResultantPasswordPolicy $accountObj
                        If ($accountFGPP -ne $null) 
						{	$maxPasswordAgeTimeSpan = $accountFGPP.MaxPasswordAge
                        } 
						Else 
						{	$maxPasswordAgeTimeSpan = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge
                        }
                    } 
					Else 
					{	$maxPasswordAgeTimeSpan = (Get-ADDefaultDomainPasswordPolicy).MaxPasswordAge
                    }
                    If ($maxPasswordAgeTimeSpan -eq $null -or $maxPasswordAgeTimeSpan.TotalMilliseconds -eq 0) 
					{	Return "MaxPasswordAge is not set for the domain or is set to zero!"
                    } 
					Else 
					{	Return ($passwordSetDate + $maxPasswordAgeTimeSpan)
                    }
                }
            }
        }
    }
}

Try { Import-Module ActiveDirectory -ErrorAction Stop }
Catch { Write-Host "Unable to load Active Directory module, is RSAT installed?" -ForegroundColor Red; Exit }



$Result = @()
$Users = $ou | foreach {Get-ADUser -searchbase $PSItem -Filter {enabled -eq $true} -Properties GivenName,sn,PasswordExpired,PasswordLastSet,PasswordNeverExpires,EmailAddress}
ForEach ($User in $Users)
{	$Result += New-Object PSObject -Property @{
		'Last Name' = $User.sn
		'First Name' = $User.GivenName
		UserName = $User.SamAccountName
        Email = $User.EmailAddress
		Expiration = $($User | Get-XADUserPasswordExpirationDate)
	}
}

#Select only the passwords within the specified expiration notification period
$Result = $Result | Where {$PSItem.expiration -lt $ExpiresBefore -or $PSItem.expiration -eq "Expired"} | Select 'Last Name','First Name',UserName,Expiration | Sort Expiration -descending

#Produce a CSV
#$Result | Export-Csv $path\ExpirationReport.csv -NoTypeInformation



#Send Notification Email
foreach ($User in $Result) {
    #DOn't sent email if the password is already expired
    if ($user.expiration -match "Expired") {continue} 

    $daysToExpire = (new-timespan -start (get-date) -end $User.expiration).Days

    $mailparams = @{
	    From = $From
        Subject = "[WARNING] Your Company Password expires in $daysToExpire days!"
	    To = $user.Email
	    SMTPServer = $SMTPServer
    }

    $Body = `
@"
<h3>Your password for account $($User.username) expires: $($User.Expiration)</h3>
<p>In order to ensure continued access to the environment, you must reset your password before this date. Please <a href="http://windows.microsoft.com/en-us/windows/change-windows-password#change-windows-password=windows-7">perform the password reset procedure</a>.</p>
<p>If you have any questions or concerns, please open a ticket with the Helpdesk.</p>
<p>Thank you for your continued assistance in keeping Company information safe and secure.</p>
<p>--Your IT Team</p>
<p><small>This email is generated by a scheduled task.</small></p>
"@

    Send-MailMessage @mailparams -Body $Body -BodyAsHTML

} #Foreach