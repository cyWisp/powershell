[CmdletBinding(SupportsShouldProcess=$True)] 
Param( 
    [Parameter(Mandatory = $True)] 
    [String]$CSVFile
)

$ErrorActionPreference = "SilentlyContinue"
If ($Error) {$Error.Clear()}

If (!(Test-Path $CSVFile)) {
	Write-Host
	Write-Host "`t Invalid CSV File provided as input." -ForegroundColor Yellow
	Write-Host "`t $CSVFile Not Found." -ForegroundColor Yellow
	Write-Host
}
Else {
	$CSVCheck = Import-CSV -Path $CSVFile
	If (!($CSVCheck)) {
		Write-Host
		Write-Host "`t $CSVFile Contains No Data For Input." -ForegroundColor Yellow
		Write-Host; exit
	}
	Write-Host
	Write-Host "`t Working. Please wait ..." -ForegroundColor Yellow
	Write-Host
	$HomePath = Split-Path -Parent $MyInvocation.MyCommand.Definition
	If (Test-Path "$HomePath\ReportFile.txt") {
		Remove-Item -Path "$HomePath\ReportFile.txt" -Force
	}
	New-Item "$HomePath\ReportFile.txt" -Type File -Force -Value "===========================================================================" | Out-Null
	Add-Content "$HomePath\ReportFile.txt" "`r `n"
	Add-Content "$HomePath\ReportFile.txt" "Reporting Group-Membership of Users From Input File: $CSVFile" 
	$Today = Get-Date -Format F
	Add-Content "$HomePath\ReportFile.txt" "Report Created On: $Today"
	Add-Content "$HomePath\ReportFile.txt" "==========================================================================="
	Add-Content "$HomePath\ReportFile.txt" "`r `n"
	Import-Module ActiveDirectory
	Import-Csv -Path $CSVFile | Where-Object { $_.PSObject.Properties.Value -NE $Null} | ForEach-Object {
		If ($_.UserLoginID -NE $Null) {
			$UserName = $_.UserLoginID
			$UserName = $UserName.ToUpper().Trim()
			Try {
				Write-Host "`t `t Status: Checking User-Account $UserName ..." -ForegroundColor Green
				$Res = (Get-ADPrincipalGroupMembership $UserName | Measure-Object).Count
				If ($Res -GT 0) { 
        				Add-Content "$HomePath\ReportFile.txt" "The User $UserName Is A Member Of The Following AD Groups:" 
       					Add-Content "$HomePath\ReportFile.txt" "---------------------------------------------------------------" 
        				Get-ADPrincipalGroupMembership $UserName | Select-Object -Property Name, GroupScope, GroupCategory | Sort-Object -Property Name | FT -A | Out-File "Test2.txt"
					Add-Content "$HomePath\ReportFile.txt" -Value (Get-Content "Test2.txt")
					Remove-Item "Test2.txt" -Force
					Add-Content "$HomePath\ReportFile.txt" "`r `n"
    				}
			}
			Catch {
				[System.Exception] | Out-Null
				Add-Content "$HomePath\ReportFile.txt" "ERROR: $UserName Not Found as a Valid User-Account in AD."
				Add-Content "$HomePath\ReportFile.txt" $Error; $Error.Clear()
				Add-Content "$HomePath\ReportFile.txt" "`r `n"
			}
		}
	}
	Remove-Module ActiveDirectory
	If (Test-Path "$HomePath\ReportFile.txt") {
		Write-Host
		Write-Host "`t Task Completed. For Detailed Information Check the Report File:" -ForegroundColor Yellow
		Write-Host "`t $HomePath\ReportFile.txt" -ForegroundColor Yellow
		Write-Host
	}
}
If ($Error) {$Error.Clear()}