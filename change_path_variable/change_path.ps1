# Define command line arguments
param(
    [Parameter(Mandatory=$true)][String]$path
)

# Define a variable to hold the current path
$current_path = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path 

# Make sure the desired path exists or exit
if (Test-Path $path){
        $new_path = "$current_path;$path"
} else {
    write-host("[x] Requested path does not exist...")
    exit
}

# Output the current path and the value to be appended
write-host("[*] Current path: `n`n$($current_path)`n")
write-host("`n[*] Appending $($path)`n`n")

# Append the value to the path variable
Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $new_path

# Capture the new path and output it before exiting
$appended_path = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path 
write-host("[*] Appended path: `n`n$($appended_path)")
