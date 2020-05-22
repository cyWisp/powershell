# Will create a zip archive given archive name and target folder

### Parameters ###
param(
	[string]$archive_name,
	[string]$target
)

### Functions ###
function usage {
	Write-Host("[!] Usage: ./$($MyInvocation.MyCommand.Name) <Archive Name> <Target Directory>")
	exit
}

function zip_archive {
	Write-Host("[+] Compressing $($target)...")
	Compress-Archive -Path $target -DestinationPath $archive_name -CompressionLevel "Fastest"	
	Write-Host("[*] Done...")
}

### Main ###
if ($PSBoundParameters.Count -ne 2) {
	usage
	Write-Host("[x] Please supply at least two parameters... ")
} elseif ((Test-Path $target) -eq $False ){
	Write-Host("[x] $($target) does not exist...")
	usage
} else {
	zip_archive
}


