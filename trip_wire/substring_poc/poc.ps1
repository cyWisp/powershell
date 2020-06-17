$str = "this/path/like/this"

$i = $str.LastIndexOf("/")
$sub = $str.SubString($i + 1)

write-host($sub)