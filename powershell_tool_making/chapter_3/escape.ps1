# this demonstrates how to escape characters

$var_1 = "This is some text with a newline`nhere's the newline"
write-host($var_1)

$computer = "randmoness"
write-host("the `$computer variable contains " + $computer)

$escape_the_escape = "``n escaping the newline character"
write-host($escape_the_escape)

$tab_character = "``t escaping the tab character"
write-host($tab_character)

$filter_1 = "name = 'BITS'"
$computer = 'BITS'
$filter_2 = "name = '$computer'"

write-host($filter_1 + "`n" + $computer + "`n" + $filter_2)