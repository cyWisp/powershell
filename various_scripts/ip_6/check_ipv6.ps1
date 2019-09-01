$ipv_6 = $false
$arrInterfaces = (Get-WmiObject -class Win32_NetworkAdapterConfiguration -filter "ipenabled = TRUE").IPAddress

foreach ($i in $arrInterfaces) {
    $ipv_6 = $ipv_6 -or $i.contains(":")
}

if ($ipv_6){
    write-host("[*] IPv6 Enabled...")
}
else {
    write-host("[*] IPv6 Disabled...")
}
