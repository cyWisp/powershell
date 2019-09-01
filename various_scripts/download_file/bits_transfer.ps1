# Using Start-BitsTransfer

param(
    [string]$url,
    [string]$output_file_name    
)

$output = "$PSScriptRoot\$output_file_name"

Import-Module BitsTransfer

Start-BitsTransfer -Source $url -Destination $output
