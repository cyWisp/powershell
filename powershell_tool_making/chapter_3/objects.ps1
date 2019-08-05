# this demonstrates the use of members and variables in objects

#$svc = Get-Service
#$svc[0].name                #get the first object's name property
#$name = $svc[1].name
#$name.length                #get the length property
#$name.ToUpper()             #invoke the ToUpper method


$svc = Get-Service

write-host("First service: " + $svc[0].name.ToUpper())
write-host("Second service: " + $svc[1].name.ToUpper())

# get the first 5 services

write-host("First 5 services: ")
for($i = 0; $i -le 4; $i++){
    write-host($svc[$i].name.ToUpper())
}




