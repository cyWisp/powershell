# Snapshot Baselines for Change Management, Auditing, Threat Hunting, and Troubleshooting

So, around 2003 I wrote a very simple SNAPSHOT.BAT script for the Windows day of SANS Security Essentials (SEC401.5) to capture the current operational state of a Windows box to a bunch of text files for the sake of change management, auditing, troubleshooting, and having a comparison baseline for detecting malicious changes (today this is called "threat hunting" or "know normal", but back then it was just common sense, an idea that's been around forever in Unix shops).

Snapshot.ps1 is the PowerShell version of the same thing.  There are much more comprehensive solutions now (like Dave Hull's wonderful [Kansa](https://github.com/davehull/Kansa) project) but I've deliberately kept the Snapshot.ps1 script as simple as possible for teaching purposes and to have as low a barrier to entry as possible.  I wanted something that was free, did not require special forensics or analysis tools, only required very basic PowerShell coding skills, and could be easily modified to run more tools (like from Sysinternals) to capture more data if desired.  

See Snapshot-Wrapper.ps1 for a starter script to be run on at-risk machines as a scheduled task every night or weekend. 

## Examples
Run the Snapshot.ps1 script and wait a few minutes:

```powershell
.\Snapshot.ps1 -verbose
```

After a few minutes, depending on the speed of your computer, a new subdirectory will be created and filled with a variety of XML, TXT and CSV files.  The folder is named after your computername and the current time, e.g., COMPUTER-2018-11-3-1-22.  

Some files are just flat TXT or CSV files, so they can be easily examined by hand: 

```powershell
notepad.exe MSINFO32-Report.txt

Get-Content Audit-Policy.txt
```

Most files are XML, which makes them easier to use when performing snapshot comparisons, but if you want to examine the data with your eyes, try these examples: 

```powershell
Import-CliXml services.xml

Import-CliXml processes.xml | out-gridview
```

And you can always convert the XML data to a CSV file or to some other text format which is easier to examine or compare (starting with XML, it's easy to convert data to other formats):

```powershell
Import-CliXml drivers.xml | 
Select Name,Description,State,StartMode | 
Export-Csv drivers.csv

.\drivers.csv  #Opens in Excel  
```

What about comparing the files across multiple snapshots?  These could be compared using a variety of free tools, including PowerShell's Compare-Object, Notepad++, fc.exe, diff.exe, and others:  

http://en.wikipedia.org/wiki/Comparison_of_file_comparison_tools



