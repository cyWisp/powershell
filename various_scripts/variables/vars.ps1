# using $_.

$names = ("rob", "tom", "bill")

foreach ($name in $names){
    write-host($name)
}