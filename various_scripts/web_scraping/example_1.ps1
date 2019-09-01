# Web Scraping Example 1

param(
    [string]$site_url
)
function test_params($url_arg){
    if ((Get-Variable -Name url_arg).Value){
        return
    }
    else{
        write-host("[!] Please provide a valid URL!")
        exit
    }
}
function get_html($site){
    $html = Invoke-WebRequest -Uri $site
    $links = $html.Links
    $link_targets = $html.Links | select href
    return $html, $links, $link_targets
}

test_params($site_url)

$html, $site_links, $site_link_targets = get_html($site_url)

write-host("[*] Site HTML: ")
write-output($html)

write-host("[*] Site Links: ")
write-output($site_links)

write-host("[*] Link Targets: ")
foreach($link in $site_link_targets){
    write-host($link)
}


