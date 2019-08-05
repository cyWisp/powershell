# this script will gather running processes and write them to a text file

$processes = Get-Process
new-item "./processes.txt" -type File
add-content "./processes.txt" -Value $processes

$network = ipconfig /all
new-item "./networking.txt" -type File
add-content "./networking.txt" -Value $network

write-host("[*] Done...")

