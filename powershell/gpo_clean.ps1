Get-GPO -All | Sort-Object displayname | Where-Object { If ( $_ | Get-GPOReport -ReportType XML | Select-String -NotMatch "&lt;LinksTo&gt;" )
{
Backup-GPO -name $_.DisplayName -path C:\Users\Public\GPOBackups
$_.DisplayName | Out-File .\UnLinkedGPOS.txt -Append
#$_.Displayname | remove-gpo -Confirm
}}