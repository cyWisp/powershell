# Using Invoke-WebRequest
# Download a file from the web
# Using an image in this case

param(
    [string]$url
)

$output = "$PSScriptRoot\test.jpg"
$start_time = Get-Date

Invoke-WebRequest -Uri $url -Outfile $output