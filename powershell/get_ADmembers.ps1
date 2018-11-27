get-distributiongroup | ForEach-Object {
$groupName = $_
Get-DistributionGroupMember -Identity $groupname.Name | ForEach-Object{
    [pscustomObject]@{GroupName=$groupname;groupMember=$_.Name}
    }
} | Group-Object -Property GroupMember | 
    Select-object Name, @{Name=‘Groups‘;Expression={$_.Group.GroupName}}