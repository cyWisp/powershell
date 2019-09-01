# Web Scraping Practice 1

param(
    [string]$url,
    [string]$mode
)

function get_html($target_url){
    $html = Invoke-WebRequest -Uri $target_url
    return $html
}

function get_links($target_url){
    $links = (Invoke-WebRequest -Uri $target_url).Links
    return $links
}

function get_link_href($target_url){
    $hrefs = (Invoke-WebRequest -Uri $target_url).Links | select href
    return $hrefs
}

function inner_text_and_href($target_url){
    $output = (Invoke-WebRequest -Uri $target_url).Links | select innerText, href
    return $output
}

function get_form_fields($target_url){
    $form_fields = (Invoke-WebRequest -Uri $target_url).Forms.fields
    return $form_fields
}

function get_images($target_url){
    $site_html = Invoke-WebRequest -Uri $target_url -UseBasicParsing
    $images = $site_html.Images.src

    write-host($images)

    # foreach($image in $images){
    #     write-output("$target_url" + "$image")
    #     $file_name = $image | Split-Path -Leaf
    #     write-host("[*] Downloading $file_name")
    #     Invoke-WebRequest -Uri ($target_url + $image) -OutFile $file_name
    #     write-host("[*] Downloading $image")
    #     Invoke-WebRequest -Uri $image -OutFile "./$image" Split-Path -Leaf
    # }

    #return $images 
}

function validate_params($url_var){
    if ((Get-Variable -Name url_var).Value){
        return
    }
    else {
        write-host("[!] Please provide a valid URL!")
        exit
    }
}

# '--__main__--'
validate_params($url)
get_images($url)



