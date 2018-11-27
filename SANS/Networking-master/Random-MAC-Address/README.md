# Assign Random MAC Address

Changing the hardware [MAC address](http://en.wikipedia.org/wiki/MAC_address) on network interface cards is useful for maintaining privacy and security testing. On Windows 7 and later, the MAC address for 802.11 wireless interfaces must sometimes be specially crafted in order for the operating system to accept it.

Here is a simple little PowerShell script for changing MAC addresses: New-MACaddress.ps1.

The New-MACaddress.ps1 script will:

* Set the appropriate Windows registry value to override the default MAC address for a NIC.

* If you have multiple NICs, the script will ask you which to modify, or you can pass in the NIC number as an argument.

* The MAC will be random, except that it will have a valid manufacturer identifier from a common vendor like Intel, Apple or Netgear.

* By default, the script changes the MAC, releases the DHCP lease for that one NIC, disables the NIC, enables the NIC, and then renews its DHCP lease again; if you don't want this behavior, use the -DoNotResetInterface switch, but note that the new MAC address will not become effective until after the NIC is reset.

* Note that many interfaces, such as for your particular 802.11 wireless card, will not accept a custom MAC address unless a special bit in the MAC indicates that it has been customized. If this is the case for your particular NIC, use the -Wireless switch to set that special bit.

## Prerequisites
The New-MACaddress.ps1 script requires PowerShell 2.0 or later.

You must be a member of the local Administrators group.

## Examples
To select a random MAC address with a valid vendor ID number, and either assign the MAC to the sole physical interface, or, if there are multiple interfaces, prompt the user to select the desired interface:

```powershell
.\new-macaddress.ps1
```

To delete the registry value for the custom MAC address so that the built-in MAC of the NIC will be used instead (revert to factory default):

```powershell
.\new-macaddress.ps1 -resetdefault
```

To modify the registry, but not disable and enable the NIC, and not release or renew any DHCP leases:

```powershell
.\new-macaddress.ps1 -donotresetinterface
```

Note: If you examine the source code, you'll find a few other options for the random-mac() function to play with too.

## Background
The Media Access Control ([MAC](http://en.wikipedia.org/wiki/MAC_address)) address is a 48-bit number built into a Network Interface Card (NIC) by the manufacturer, though the MAC address can usually be changed or "spoofed" on Windows by modifying a registry value named "[NetworkAddress](http://msdn.microsoft.com/en-us/library/ff564512(VS.85).aspx)" in a key associated with that particular NIC.

With IPv4, a host can discover the MAC of another network-attached device using the Address Resolution Protocol ([ARP](http://en.wikipedia.org/wiki/Address_Resolution_Protocol)) or, with IPv6, with ICMP Neighbor Discovery Protocol ([NDP](http://en.wikipedia.org/wiki/Neighbor_Discovery_Protocol)).

To see your current MAC address(es), open CMD or PowerShell, run "ipconfig.exe /all" and look for the "Physical Address" line(s). Your MAC address(es) will look similar to "00-0D-28-3F-2B-54" because they are formatted in hexadecimal.

Some 802.11 wireless NIC drivers will not accept a customized MAC address unless the "[locally administered](http://en.wikipedia.org/wiki/MAC_address)" bit is set in the first octet of the MAC address (this is what the -wireless switch does in the script).

While IP addresses change frequently, MAC addresses generally do not, hence, unchanging MAC addresses are a privacy risk because they can be used for device tracking over long periods of time. Changing one's MAC address is also useful for a variety of security purposes (some good, some bad) such as in penetration testing.

## Similar Tools
There are many utilities for changing MAC addresses on Windows, but some are graphical-only and some are not open source or in the public domain. Here are some of the more popular ones:

* [Technitium MAC Address Changer](http://www.technitium.com/tmac/index.html)

* [Lizard Systems Change MAC Address](http://lizardsystems.com/change-mac-address/)

* [KLC SMAC](http://www.klcconsulting.net/smac/)

* [Zokali MAC Address Changer](http://www.zokali.com/win7-mac-address-changer)


## Update History
* 6.Oct.2011: First posted to SANS.
* 1.Jun.2017: Moved to GitHub.
