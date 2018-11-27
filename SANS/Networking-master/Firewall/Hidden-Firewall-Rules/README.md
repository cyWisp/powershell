# Get Hidden Windows Firewall Rules For Services

It's crazy, but Microsoft's graphical Windows Firewall snap-in cannot show all the firewall rules on Windows Server or Windows client systems.

There are Microsoft's "static" service hardening firewall rules, and also the "configurable" rules often managed by third-party installer programs.  These service hardening rules are enforced prior to any rules visible in the Windows Firewall MMC.EXE console snap-in.  

## Get-NetFirewallServiceHardeningRule.ps1
The -PolicyStore parameter must be either "StaticServiceStore" or "ConfigurableServiceStore".

```powershell
 Get-NetFirewallServiceHardeningRule -PolicyStore StaticServiceStore | Out-GridView
 ```

## Reference
See https://technet.microsoft.com/en-us/library/cc755191(v=ws.10).aspx

Registry location of the StaticServiceStore rules:

    HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System

Registry location of the ConfigurableServiceStore rules:

    HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Configurable\System

If you wish, reading the registry directly is much faster:

```powershell
$key = Get-Item -Path 'HKLM:\SYSTEM\CurrentControlSet\Services\SharedAccess\Parameters\FirewallPolicy\RestrictedServices\Static\System'

$key.GetValueNames() | ForEach { $key.GetValue($_) } 
```

But you'll have to parse the fields yourself and expand the indirect strings (see Expand-IndirectStrings.ps1 script).

