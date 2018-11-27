# Color Highlight The Packet Fields In WinDump Output

[WinDump.exe](https://www.winpcap.org/windump/) is a free command-line packet sniffer and protocol analyzer for Windows (similar in [command-line options](http://www.tcpdump.org/tcpdump_man.html) to tcpdump for UNIX/Linux). 

Staring at the output of WinDump for hours can cause eye strain, especially when sniffing in verbose mode or when showing the output on a projector to an audience.

Sniff.ps1 is a badly-written and inefficient script to colorize the output of the WinDump packet sniffer on Windows.  It displays the packet fields of each line in a different color, such as source IP, destination IP, port numbers, etc.  It can also insert zero or more blank lines in between each line of output for readability, such as when the font size of the shell is increased.

## Examples
To have the script simply guess which network adapter to listen on and start sniffing:

```powershell
.\sniff.ps1
```

To have the script ask you which network adapter to use:

```powershell
.\sniff.ps1 -ask
```

To add one or more blank lines in between each line of output (nice for teaching):

```powershell
.\sniff.ps1 -spacing 1
```

To specify additional WinDump command-line options (-options parameter optional) just put the arguments inside double-quotes:

```powershell
.\sniff.ps1 -options "-v -t -X not arp and not port 1900"

.\sniff.ps1 "-s 500 tcp port 80" -ask

.\sniff.ps1 "-r capturefile.pcap -X -s 0" -spacing 2
```

If the script is in your PATH or the Sniff() function from inside the script has been copied into your profile script (see $profile), you don't need the folder path or filename extension, and you can abbreviate the full names of the parameters:

```powershell
sniff

sniff -a -s 1

sniff "-t -X not port 3389"
```

If you want to change the colors, they are listed in one spot inside the script, so they are easy to find and edit.

If you don't want to use the Sniff.ps1 wrapper, but you do want the color highlighting sometimes, open the script and copy out the Colorize-WinDump() filter (which is inside the Sniff() function). Copy the filter code to another file for dot-sourcing or paste the code into your profile script, then you can pipe WinDump.exe output into the filter as desired:

```powershell
windump.exe -i 2 -v -X | colorize-windump
```

## Requirements & Caveats
Script requires PowerShell 2.0 or later. 

WinDump.exe and the WinPcap driver must be installed before running script.

WinDump.exe must be in the PATH or you must edit the $WindumpPath variable in the script.

Not every protocol can be colorized by the script, so the script defaults to showing in monochrome the output lines it can't parse correctly.

WinDump's -e switch, for showing the link-level header, is not supported, but the monochrome output will still be shown. Other verbose switches, such as -tttt, -vvv and -X, are supported though.

The default color scheme assumes that your shell's background color is black, which is not the PowerShell default, but you can easily change your background color (right-click the shell's titlebar > Properties > Colors) and you can easily edit the colors defined inside the script (they are all listed in one spot in the script for easy editing).

It runs slowwwww... Someday I'll get around to sprucing it up...

## Update History
* 22.Oct.2009: First posted to SANS.
* 1.Jun.2017: Moved to GitHub.
