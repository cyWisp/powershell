# Downloads using the System.Net.WebClient class

param(
    [string]$url
)

$output = "$PSScriptRoot\test_2.jpg"
$start_time = Get-Date

$web_client = New-Object System.Net.WebClient
$web_client.DownloadFile($url, $output)

$end_time = Get-Date

Write-Output("Download Duration: $($end_time.subtract($start_time).Seconds) seconds...")