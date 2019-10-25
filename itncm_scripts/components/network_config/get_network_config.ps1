function get_network_properties($network_config){
    $output_array = @()

    foreach($item in $network_config){
        $properties = @{
            HostName = $item.DNSHostName
            IPAddress = $item.IPAddress
            MacAddress = $item.MACAddress
        }
        $new_obj = New-Object -TypeName PSObject -Property $properties
        $output_array += $new_obj
    }
    foreach($o in $output_array){
        write-output("HOST:IP:MAC,$($o.HostName),$($o.IPAddress),$($o.MacAddress)`n")

    }
}

$network = Get-WmiObject -Class Win32_NetworkAdapterConfiguration -Filter IPEnabled=TRUE -ComputerName .
get_network_properties($network)