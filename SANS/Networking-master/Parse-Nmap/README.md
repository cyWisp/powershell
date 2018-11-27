# Parse Nmap
The [nmap port scanner](http://insecure.org/) can produce XML output of the results of its scanning and OS fingerprinting work. But how can these XML files be conveniently handled from the command line when you want to query and extract specific data or to convert that data into other formats like CSV or HTML files?

PowerShell has great XML handling capabilities, so let's look at a script which takes nmap XML as input and converts that data into PowerShell objects where each object represents a host on the network and the properties of those objects contain the data from the scan. Once we have our scan results as an array of PowerShell objects, it becomes easy to pipe those objects into other cmdlets and scripts. (This script is from the Securing Windows and PowerShell Automation [SEC505](https://sans.org/sec505) course at SANS.)

## Prerequisites
To follow along with the examples below, get the samplescan.xml log file and the parse-nmap.ps1 script from the SEC505 zip file on the Downloads page of this blog. The scripts zip file contains these two files (in the Day1-PowerShell folder) plus many other folders and files. Every script in the zip file is in the public domain, so feel free to do whatever you wish with them. This blog has a number of articles about these scripts.

You also need PowerShell running of course and then set your working directory to the folder where you placed the log file and script. Don't forget that you must give the full path to the script at the command line, and that the current working directory is ".".

Finally, by default PowerShell does not permit scripts to run, so right-click on the PowerShell shortcut in the Start Menu, select Run As Administrator, then execute "set-executionpolicy unrestricted", which means you can now run any script from any source, so don't run scripts you download from blogs!

## Examples
To process just one XML log file:

```powershell
.\parse-nmap.ps1 -path samplescan.xml
```

And then the output will look like the following, but remember, this output is not really text, the output is an array of .NET objects with properties!

```
FQDN           : srv-4mm1vr3.sans.org
HostName       : srv-4mm1vr3
Status         : up
IPv4           : 10.54.23.2
IPv6           : <no-ipv6>
MAC            : <no-mac>
Ports          : open:TCP:135:msrpc
                 open:TCP:139:netbios-ssn
Services       : TCP:135:msrpc:Microsoft Windows RPC <100%-confidence>
OS             : Microsoft Windows 7 <95%-accuracy>
Script         : <no-script>
FQDN           : wks-88d70.sans.org
HostName       : wks-88d70
Status         : up
IPv4           : 10.54.23.3
IPv6           : <no-ipv6>
MAC            : <no-mac>
Ports          : open:TCP:135:msrpc
                 open:TCP:139:netbios-ssn
Services:      : open:TCP:135:msrpc:Microsoft Windows RPC <100%-confidence>
OS             : Microsoft Windows Server 2008-R2 <93%-accuracy>
Script         : <no-script>
FQDN           : srv-9ryc3.sans.org
HostName       : srv-9ryc3
Status         : up
IPv4           : 10.54.23.4
IPv6           : <no-ipv6>
MAC            : <no-mac>
Ports          : open:TCP:135:msrpc
                 open:TCP:139:netbios-ssn
Services       : open:TCP:135:msrpc:Microsoft Windows RPC <100%-confidence>
OS             : Microsoft Windows XP SP2 <100%-accuracy>
Script         : <no-script>
```

To process a bunch of XML log files and consolidate their output:

```powershell
.\parse-nmap.ps1 -path *.xml 
```

Or, if you prefer piping instead:

```powershell
dir *.xml | parse-nmap.ps1
```

To extract the IP addresses and hostnames of the machines fingerprinted as running Windows XP:

```powershell
.\parse-nmap.ps1 samplescan.xml | 
where {$_.OS -like "*Windows XP*"} |
format-table IPv4,HostName,OS
```

To find the hosts listening on TCP/23 for telnet:

```powershell
.\parse-nmap.ps1 samplescan.xml | 
where {$_.Ports -like "*open:tcp:23*"}
```

The "-like" operator is for simple wildcard matching, while the "-match" operator is for regular expression matching. You have the full .NET Framework regular expression engine available to you. Also, note that the Ports property is a space-character-delimited list of scanned ports in the format of state:protocol:portnumber:servicename (see the nmap documentation) for each port in the list.

To find the hosts listening on either TCP/80 or TCP/443 or both:

```powershell
.\parse-nmap.ps1 samplescan.xml |
where {$_.Ports -match "open:tcp:80|open:tcp:443"}
```

## Export to CSV or HTML (-OutputDelimiter)
The script uses a parameter named "-OutputDelimiter" to separate the strings in the Ports, Services, OS and Script properties. The default is a newline, but you will want to change the delimiter to a space character or some other symbol when exporting to a comma-delimited file or HTML report (whatever is best for how you intend to save, parse or print the data). The default is a newline to make the output easier to read within the shell.

To export the data to a CSV file for grepping, import into a spreadsheet, etc.:

```powershell
.\parse-nmap.ps1 samplescan.xml -outputdelimiter " " |
where {$_.Ports -match "open:tcp:80"} |
export-csv weblisteners.csv
```

Then you could later re-import from the CSV file into a new array, keeping the same properties as before for the sake of further processing:

```powershell
$data = import-csv weblisteners.csv
$data | where {($_.IPv4 -like "10.57.*") -and ($_.Ports -match "open:tcp:22")}
```

To export the processed data to an HTML file for viewing in a browser:

```powershell
.\parse-nmap.ps1 samplescan.xml -outputdelimiter " " |
select-object IPv4,HostName,OS |
convertto-html | 
out-file \serversharereport.html
```

## View RunStats Information (-RunStatsOnly)
The script has a -RunStatsOnly switch which shows general information about the scan instead of information about each scanned host; for example, the runstats output includes the scan's start time, end time, command-line arguments when the scan was run, etc. Keep in mind that different versions of nmap have different XML output formats, so not every field can be shown from every scan file.

## Caveats
The script is slower than a C++ binary, of course; for example, on an Intel Core i7 at 3.6GHz, it can process host records in the XML file at a rate of about 900 records/second, which isn't blazing, but hopefully good enough. I'm sure there are other inefficiencies and shortcomings in the script too, so feel free to modify the script as you wish, it's in the public domain (or let me know how to improve it!).

Also, if you are unhappy with using PowerShell, there are great resources out there to parse nmap XML output in Perl or in Python.

## To Learn More
Get the latest version of PowerShell (for free) from http://www.microsoft.com/powershell/

Get the nmap scanner (for free) from http://insecure.org (or http://nmap.org) and find the documentation.

Get PowerShell training (not free) as part of the SANS Institute's six-day [Securing Windows](https://sans.org) course.  :-)

## Update History
* 9.July.2009: script edited to increase performance.

* 18.July.2009: the -runstatsonly switch added.

* 30.Jan.2010: fixed output issue with the -runstatsonly switch.

* 23.May.2010: support for nmap script output added.

* 1.Nov.2010: fixed bug for FQDN output.

* 16.Nov.2010: removed a PowerShell 2.0 dependency

* 14.Mar.2014: fixed an FQDN parsing bug.

* 6.Jun.2015: improved performance, added the -Verbose switch.

* 1.Jun.2017: moved to GitHub

