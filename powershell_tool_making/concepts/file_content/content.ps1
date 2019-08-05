# demonstrates how to read file content

param(
	[string]$file_name
)

$arr = @()

foreach($line in Get-Content $file_name){
	$arr += $line
}

foreach($item in $arr)
{
	write-host($item)
}
