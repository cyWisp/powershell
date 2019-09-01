# arguments in powershell

param(
    [string]$var_1
)

#write-output((Get-Variable -Name var_1).Value)

if ((Get-Variable -Name var_1).Value){
    write-host("variable exists")
}
else{
    write-host("variable does not exist")
}