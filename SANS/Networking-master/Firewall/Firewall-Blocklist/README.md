# Windows Firewall Script To Block IP Addresses And Country Network Ranges

The host-based Windows Firewall is easily managed through scripts and the NETSH.EXE command-line tool. This article is about a simple PowerShell script which can create rules to block inbound and outbound access to thousands of IP addresses and network ID ranges, such as for attackers and unwanted countries.

The script can also create firewall rules which apply only to certain interface profile types (public, private, domain, any) and/or only to certain interface media types (wireless, ras, lan, any); for example, you might wish to only block packets going through an 802.11 NIC (wireless) but only while not at home or at the office (public). 

## Requirements
The script requires PowerShell 1.0 or later.

You must be a member of the local Administrators group.

The script runs on Windows Server 2008, Windows Vista, and later operating systems.

A text file containing addresses to block must be passed into the script as an argument. This file must have one entry per line, each line containing either a single IP address, a network ID using CIDR notation, or an IP address range in the form of StartIP-EndIP, for example, "10.4.0.0-10.4.255.254". Both IPv4 and IPv6 are supported. Blank lines and comment lines are ignored; a comment line is any line that does not begin with a number or hex letter. Even if the input file was originally created for Apache or iptables, it can still be used as long as the formatting is compatible (or made compatible with a bit of scripting).


## Block Countries, Attackers, Spammers and Bogons
You can obtain lists of IP addresses and network ID ranges to block from a variety of sources for a variety of purposes.

Here are a few sources to try:

* http://www.ipdeny.com/ipblocks/

* http://www.okean.com/thegoods.html

* http://www.countryipblocks.net/

* http://www.wizcrafts.net/iptables-blocklists.html

* http://www.iblocklist.com

* http://lite.ip2location.com

Note: If you also want to block the resolution of unwanted hostnames in DNS, there is another script for that here.

## Examples
To create rules to block all inbound and outbound packets to the IP addresses and CIDR networks listed in a file named iptoblock.txt:

```powershell
import-firewall-blocklist.ps1 -inputfile iptoblock.txt
```

To block addresses only on public network interfaces:

```powershell
import-firewall-blocklist.ps1 -inputfile iptoblock.txt -profiletype public
```

To block addresses only on wireless network adapter cards:

```powershell
import-firewall-blocklist.ps1 -inputfile iptoblock.txt -interfacetype wireless
```

To delete the firewall rules created by the script whose names start with "iptoblock*":

```powershell
import-firewall-blocklist.ps1 -rulename iptoblock -deleteonly
```

The script defaults to looking for an input file named "blocklist.txt", so you can also simply create that file in the same directory as the script and then run the script with no arguments:

```powershell
import-firewall-blocklist.ps1
```

Note: By default the script will create rules which are named after the input file; for example, with an input file named "Attackers.txt", the script will create rules named like "Attackers-#001". If you wish to override the default rule name, use the -RuleName parameter with the script when both creating and deleting the rules.

## Caveats
For compatibility reasons, each firewall rule will contain only 200 IP addresses or network ID ranges; hence, when importing 5000 IP addresses or network ranges to block from a file named "Attackers.txt", the script will create 25 inbound rules and 25 outbound rules, each rule named "Attackers-#001" through "Attackers-#025". Don't worry, the script creates or deletes all of them at once, but do take care to use a unique input file name or a unique -RuleName argument.

Blocking large numbers of IP addresses or network ID ranges (10,000 for example) appears to have relatively little performance impact, but it does take longer to launch or refresh the Windows Firewall MMC snap-in, and it does take longer to disable/enable network interfaces. This testing was done informally, however, so no hard numbers are available. Please do some testing yourself when importing large input files.

## Legal
The script is free and in the public domain, you may use it for any purpose whatsoever without restriction. However, that being said...

THIS SCRIPT IS PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE. ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF ANY SUCH DAMAGE. IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF LIABILITY, THEN DO NOT DOWNLOAD OR USE THE SCRIPT. NO TECHNICAL SUPPORT WILL BE PROVIDED.

Please test the script on non-production servers first, then test on a production server only during off-peak hours and only after having made a full backup.

## Update History
* 25.Oct.2011: first posted to SANS.
* 1.Jun.2017: moved to GitHub.

