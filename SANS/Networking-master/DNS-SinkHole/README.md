# Windows DNS Server Sinkhole Domains Tool

Use this PowerShell script to manage sinkhole DNS domains using Microsoft's Windows Server DNS. The script is easy to use and can handle tens of thousands sinkhole DNS domains on local or remote Windows DNS servers. This is a script we use in the Securing Windows and PowerShell Automation course ([SEC505](https://sans.org/sec505)) at SANS conferences. 

Note: There is a different PowerShell script to manage sinkhole names in the HOSTS file instead (Update-HostsFile.ps1).

## Background
DNS servers resolve names, like "www.sans.org", to IP addresses. But there are fully-qualified domain names (FQDNs) which we do not want our users to successfully resolve, e.g., the names used for malware, spyware, phishing, scams, pornography, hate groups, bandwidth-wasting video sites, social networking sites unrelated to work, etc.

Most organizations have a "split DNS" architecture where the organization's internal DNS servers forward all their Internet name resolution requests to one or a few of their external DNS servers. The external DNS servers are usually located in the DMZ of the firewall. Only the external DNS servers can communicate with the outside world. The internal DNS servers must forward the requests they can't resolve themselves to the external DNS servers.

On the external DNS servers you can create primary zones for the domain names and FQDNs you do not want your users to resolve correctly. These DNS zones will all return an incorrect IP address, such as "0.0.0.0" or the address of an internal server, not the real address. Because the organization's internal DNS servers are configured to forward their requests to these external DNS servers in the DMZ, the internal DNS servers will cache these incorrect addresses too when the external DNS servers respond. So, when an internal client tries to resolve an unwanted DNS name, it will receive a response, but the IP address returned will be incorrect. Because an IP address of "0.0.0.0" is unreachable, these unwanted zones created on the external DNS servers are said to be "blackholed", "sinklisted" or "blocklisted".

## What to block? 
You can obtain lists of FQDNs and domain names to sinkhole for free. Some lists are only for malware, others might be just for pornography, but be aware that they are never 100% complete or accurate (you get what you pay for, so don't be surprised to find gaps a small number of false positives).

Some of the more popular sinkhole lists include (in no particular order):

* http://www.MalwareDomains.com

* http://www.Malware.com.br

* http://www.MalwareDomainList.com

* http://www.MalwareURL.com

* http://www.SomeoneWhoCares.org

* http://mtc.sri.com

* http://www.MVPs.org

* http://www.UrlBlacklist.com (not free)

From sites like the above you can download lists of FQDNs and simple domain names which can be fed into the PowerShell script for this article in order to create sinkhole zones on Windows DNS servers. If you have DNS servers running BIND, perhaps on Linux or BSD, then the sites above will also help you import sinkhole domains on those DNS servers too (scripts for sinkholing on BIND are common).

## Requirements
To use the PowerShell DNS sinkhole script you must:

Have PowerShell 2.0 or later on the computer where the script will be run, which may be the DNS server itself or another management workstation.

Use Windows Server 2003 with SP2 or later for the DNS server.

Allow network access to the RPC ports of the Windows Management Instrumentation (WMI) service from the workstation where the script will be run.

Be a member of the local Administrators group on the DNS server.

## Example Uses
To see the script's command-line options (don't forget the ".\" before the script name):

```powershell
get-help -full Sinkhole-DNS.ps1
```

To sinkhole "www.sans.org" by making it resolve to "0.0.0.0":

```powershell
Sinkhole-DNS.ps1 -Domain "www.sans.org"
```

To sinkhole all the FQDNs and domain names listed in file.txt, removing any "www." leading strings, plus add a wildcard (*) record for each domain, all resolving to "0.0.0.0":

```powershell
Sinkhole-DNS.ps1 -InputFile file.txt -IncludeWildCard -RemoveLeadingWWW
```

To create sinkholed domains from file.txt on a remote DNS server named "server7.sans.org" with explicit credentials (you will be prompted for the passphrase):

```powershell
Sinkhole-DNS.ps1 -InputFile file.txt -DnsServerName "server7.sans.org" -Credential "server7\administrator"
```

To delete all sinkhole domains (and only the sinkhole domains this script created, nothing else):

```powershell
Sinkhole-DNS.ps1 -DeleteSinkHoleDomains
```

## Frequently Asked Questions (FAQ)
_Q: Are the DNS zones replicated through Active Directory?_

A: No, these are standard primary zones using a text file.

_Q: If I sinkhole 10,000 domains, will the script create 10,000 zone files?_

A: No, one zone file named "000-sinkholed-domain.local.dns" is used by all of them.

_Q: If I'm not sitting at the DNS server, because it's remote, does that DNS server need PowerShell installed?_

A: No, the local PowerShell script only talks to the WMI service on the remote DNS server.

_Q: Does the DNS server need to be a member of an Active Directory domain?_

A: No, it can be a stand-alone or a domain member.

_Q: What if I have other primary or AD-integrated zones on my DNS server?_

A: That's fine, the script will add more primary zones to whatever zones you already have.

_Q: Will the script delete or modify any of my other previously-existing zones?_

A: No, the script only touches the zones or domains that it created itself, your other DNS domains won't be changed.

## Intrusion Detection & Forensics
By default, the script will create sinkhole zones which resolve to "0.0.0.0", but there is a command-line parameter named "-SinkholeIP" with which you can set a different IP address for all your sinkholed zones. You might consider using the IP address of an internal server set up specifically for this purpose.

Your internal sinkhole IDS server, let's call it, should listen on all the likely ports which malware or attack tools might use, especially TCP 80 (HTTP) and 21 (FTP). Enable maximum logging on it. Run a packet capture tool (like WinDump, WireShark or Network Monitor) to capture full packet payloads 24×7 using circular logging, with a large maximum capture size before wrapping, of all traffic to/from the sinkhole server itself. You can install full servers for the listening ports, such as IIS for HTTP and FTP, but be careful of unintended infections. You might instead install honeypot services, or maybe something as simple as HoneyBOT, but we need to interact enough with the client so that the details of any requests can be logged. Your perimeter firewall should block and log all traffic for your sinkhole server to/from the Internet too.

The idea is that you can examine the various logs and packet captures on your sinkhole server to help identify infected machines or those users who are attempting to violate your acceptable use policies. For example, when a workstation becomes infected, that malware may attempt to resolve a known FQDN in order to download via HTTP another piece of malware; often, you can identify the type of malware simply by the URL of the file it tried to download. You might also set a default HTML page which reminds users of your acceptable use policies (and have it mention that all Internet access is logged for the sake of HR). Don't forget that you can enable debug logging on the DNS server too.

## Caveats
The script is fast when creating new sinkhole domains, even tens of thousands of them, but the script is slow when deleting (-DeleteSinkHoleDomains) or reloading (-ReloadSinkHoleDomains) these domains. These two operations will also run up a core of the CPU to over 90% while executing. How slow is "slow"? For example, in my testing, deleting or reloading 20,000 sinkhole domains on a 2.7GHz Core i7 CPU box with Server 2008-R2 required just over nine minutes. The poor performance is due to the WMI queries required.

# Windows HOSTS File Script To Block Evil Domains
Use the Update-HostsFile.ps1 PowerShell script to block bad domain names by modifying the HOSTS file on Windows computers. You can run the script manually, as a scheduled job, or push it out through Group Policy for enterprise-wide deployment. 

Why is this script any different than other HOSTS file tools out there? The script puts nine names on each line of the file, which optimizes lookup performance greatly. The script can take multiple local, SMB or HTTP paths to multiple input files to create one new HOSTS file with redundant names removed. It can create duplicate names with "www." prepended if necessary. And because it's a public domain PowerShell script instead of a licensed binary, it's easy to customize without any legal worries.

Modifying HOSTS files has a few advantages: 1) if a roaming laptop switches to a different DNS server, its HOSTS file is still used; 2) you do not need administrative rights on any DNS servers to modify your HOSTS file, you only have to be a member of the local Administrators group on your own computer; 3) in an Active Directory environment, users are (hopefully) not members of their local Administrators groups, so updates to the HOSTS file will be accomplished through Group Policy, scheduled jobs, remote command execution, or an EMS product; 4) malware will often modify the HOSTS file too, hence, overwriting that file can help to thwart malware's use of it a tiny bit; and 5) there are numerous free lists of bad domain names available on the Internet which are updated regularly (see below).

But modifying HOSTS files has some disadvantages too: 1) the larger the HOSTS file, the slower the overall name resolution performance; 2) the HOSTS file must be updated at least once per week, preferably once per day, in order to be really useful; 3) without Group Policy or a similar EMS product, managing the HOSTS files on thousands of computers can be difficult; 4) unlike DNS records which time-expire, an incorrect entry in a HOSTS file is permanent until that file is modified again; 5) if you don't trust your source(s) of bad domain lists, you may need to purchase access to a trustworthy commercial provider and/or somehow review FQDNs before they are blackholed with a HOSTS file; and 6) overwriting the HOSTS file destroys forensic evidence when malware also modifies that file.

## Examples
To see the script's command-line options (don't forget the ".&#92" before the script name):

```powershell
get-help -full Update-HostsFile.ps1
```

To add the names from www.MalwareDomainList.com to your HOSTS file and resolve them to "0.0.0.0":

```powershell
Update-HostsFile.ps1
```

To blackhole all the names listed in file.txt, remotefile.txt, and all the names from the URL shown, then make them all resolve to "10.1.1.1":

```powershell
Update-HostsFile.ps1 -FilePathOrURL "c:]folder\file.txt \\server\share\remotefile.txt http://www.malwaredomainlist.com/hostslist/hosts.txt" -BlackHoleIP "10.1.1.1"
```

Note: To input multiple files, separate each path with a space character (local drive, SMB or HTTP).

The -AddDuplicateWWW switch will add the original input names to the HOSTS file, but will also add a second entry with "www." prepended for every name which does not already begin with "www." (many browsers will prepend "www." to any name which experiences a name resolution error):

```powershell
Update-HostsFile.ps1 -AddDuplicateWWW
```

To erase the HOSTS file and add back only the standard localhost entries:

```powershell
Update-HostsFile.ps1 -ResetToDefaultHostsFile
```

## Frequently Asked Questions (FAQ)
_Q: Must the script be run with elevated privileges?_

A: Yes and no. The NTFS permissions on the HOSTS file do not allow regular users to modify it, so you must either run elevated or change the NTFS permissions on the HOSTS file to allow a non-administrative account to modify it, such as the account for a scheduled job.

_Q: How can I manage the HOSTS file on thousands of laptops?_

A: An EMS, Group Policy, Task Scheduler, SCHTASKS.EXE, etc.

_Q: Why not just do the blackholing at the DNS server?_

A: You can, and here is a script to do it, but roaming laptops often use DNS servers you don't control.

_Q: Isn't this an enormous pain-in-the-behind to manage?_

A: Yes, but so is cleaning up after malware infections (choose the lesser pain).

_Q: What about the name resolution performance penalty?_

A: The script places nine entries per line in the HOSTS file, which optimizes lookup performance, and if you also block ads this way, overall browser performance might actually improve. And if it turns out that lookup performance is too slow, reduce the number of entries you add to the HOSTS file, i.e., only blackhole what you really care about, such as the names used by rampant malware.

Note: On my test system (Core i7 2.67GHz, 6GB RAM, 64-bit Windows 7) I have 4K lines in my HOSTS file with 36K names in it, the DNS Client service is running, and the average increase in name resolution time over a default HOSTS file is about 12 milliseconds.

## Legal
The script is free and in the public domain, you may use it for any purpose whatsoever without restriction. However, that being said...

THIS SCRIPT IS PROVIDED "AS IS" WITH NO WARRANTIES OR GUARANTEES OF ANY KIND, INCLUDING BUT NOT LIMITED TO MERCHANTABILITY AND/OR FITNESS FOR A PARTICULAR PURPOSE. ALL RISKS OF DAMAGE REMAINS WITH THE USER, EVEN IF THE AUTHOR, SUPPLIER OR DISTRIBUTOR HAS BEEN ADVISED OF THE POSSIBILITY OF ANY SUCH DAMAGE. IF YOUR STATE DOES NOT PERMIT THE COMPLETE LIMITATION OF LIABILITY, THEN DO NOT DOWNLOAD OR USE THE SCRIPT. NO TECHNICAL SUPPORT WILL BE PROVIDED.

Please test the script on non-production servers first, then test on a production server only during off-peak hours and only after having made a full backup.

## Update History
* 31.Aug.2010 : Initial release.
* 14.Mar.2011: Bug fix (thanks to Seth Matheson and Tim Medin!)
* 17.Jun.2012 : Renamed the script.
* 1.Jun.2017: Moved to GitHub.
