# Block Cortana

[Privacy advocates](https://www.eff.org/deeplinks/2016/08/windows-10-microsoft-blatantly-disregards-user-choice-and-privacy-deep-dive) dislike the amount of personal information shared with Microsoft through the Windows 10 Cortana search feature.

In Windows 10 version 1607 (the "Anniversary Update" released in August 2016) Microsoft removed the easy-to-find on/off switch to disable Cortana, but at least there is a registry value named ["AllowCortana"](http://www.zdnet.com/article/windows-10-tip-turn-off-cortana-completely/) that can be set to zero to disable Cortana instead.

But will this registry value block all of Cortana's Internet usage, both now and in the future? This is unknown, but at least we can also use the built-in Windows Firewall to block all outbound Cortana network traffic, just in case. That's what this article is about.

## PowerShell Script: Block-Cortana.ps1
The Block-Cortana.ps1 PowerShell script will:

1. Set the above-mentioned AllowCortana value to zero to disable Windows 10 Cortana for all but local searches.

1. Disable all built-in Windows Firewall rules related to Cortana.

1. Add a Windows Firewall rule to block the Cortana APPX package by name from making outbound connections to the Internet.

1. Add additional Windows Firewall rules to block the outbound Internet connections of all Cortana-related EXE binaries individually, just in case blocking the Cortana APPX package by name doesn't work in the future.

1. The Block-Cortana.ps1 script is in the SEC505 zip file. Please look in the \Day1-PowerShell folder inside that zip to find the script.

To run the script, right-click PowerShell and run as administrator, then enter the path to the script, like this:

```PowerShell
    .\Block-Cortana.ps1 -Verbose
```

Then, reboot your computer to disable Cortana. The firewall rules do not require a reboot, they take effect immediately.

If you want to see the firewall rules created by the script, open the Windows Firewall graphical tool (search in the Start screen) and look in the Outbound Rules container for rules named "Block Cortana*".

In an enterprise, the script may be executed at scale through PowerShell remoting, as a Group Policy startup script, as a run-once "immediate task" with the Task Scheduler (which may itself be managed through Group Policy) and with other enterprise management tools (as we discuss in [SANS SEC505](https://sans.org/sec505)).

## Requirements
Script requires Windows 10 version 1607 or later, any edition ([here](http://www.windowscentral.com/how-check-your-windows-10-build) is how to find your version number).

The script does not require Active Directory domain membership, but it must be run with administrative privileges, i.e., as a user account in the local Administrators group.

The PowerShell [execution policy](https://technet.microsoft.com/en-us/library/ee176961.aspx) on the computer must allow running scripts.

After running the script, a reboot is required to disable Cortana, but the script does not trigger a reboot itself. If you want this, add the Restart-Computer command to the end of the script.

## Script Notes
Run the script with the optional -Verbose switch to show progress information.

Use the -EnableCortana switch to reverse out the changes made by the script. This will re-enable Cortana, re-enable the built-in firewall rules for Cortana, and delete all the firewall rules added by the script (other firewall rules will not be touched).

The script does not disable any services, terminate any processes, or delete any files related to Cortana, hence, Cortana can still be used for local searches, such as for searching for settings and apps. The script does not hide or disable any Cortana-related settings in the GUI either.

The firewall rules added by the script only block outbound packets from the Cortana APPX package binaries when destined for the Internet. It's possible that future Cortana updates might use intranet or local subnet networking in a useful way, so not all outbound packets are dropped whatsoever, only those destined for the Internet. How is "Internet" defined in the firewall rules? See the Scope tab of the firewall rules created by the script, where the keyword ["Internet"](https://www.google.com/search?as_q=windows+firewall+internet+scope+tab+rules) has a special meaning understood by the Windows Firewall. Internet traffic is not defined in the script as some set of IP address ranges that must be managed. No rules are added to drop any inbound connections (though the built-in Cortana rule which does allow inbound connections is disabled by the script).

## Future Proof?
If Microsoft plays games to prevent the above registry value or these Windows Firewall rules from working in the future, such as if Microsoft renames the Cortana APPX package or the Cortana-related EXE files, then the script can be re-run again to try to cover the new EXE binaries (I plan to update the script as necessary, but the rules are refreshed with the latest Cortana EXE paths whenever the script is run again to hopefully make script changes unnecessary).

If you wish to edit the script yourself, feel free! The code is pretty simple as far as PowerShell scripts go, and it's in the public domain.

(I also spent some time experimenting with sinkholing the DNS names for Microsoft's telemetry, Cortana and Dr Watson servers, but it breaks too much other functionality to be worth it...poison pill?)

## Legal
The Block-Cortana.ps1 script is free and in the public domain, no rights reserved. The script is provided "AS IS" without any warranties or guarantees whatsoever; use at your own risk; no technical support is available or will be provided. Cortana, Active Directory, Windows, and Windows 10 are products and/or trademarks of Microsoft Corporation throughout the Known Universe.

## Updates

20-Aug-2016: first posted.

25-Aug-2016: added more usage notes and the DNS sinkhole link.
