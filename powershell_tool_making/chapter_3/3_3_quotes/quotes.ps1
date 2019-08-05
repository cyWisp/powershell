# This demonstrates how to use quotes in a script

$var_1 = 'Robert Daglio'
$var_2 = "My name is $var_1"

write-host("Hello, $var_2")

$processes = Get-Process

for($i = 1; $i -le 5; $i++)
{
    write-host($i)
}

$count = 0
while($count -le 10){
    write-host($count)
    $count++
    if($count -eq 5){
        break
    }
    else{
        continue
    }
}