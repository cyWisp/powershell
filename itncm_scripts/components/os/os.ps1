$os_info = gwmi Win32_OperatingSystem | select caption, installdate, OSArchitecture, version, BuildNumber, servicepackmajorversion
$hostname = hostname

write-output("C010_2_R1:1:1, hostname, os_caption, install_date, os_architecture, os_version, os_build_number, service_pack_version")
write-output("C010_2_R1:1:1, $hostname, $($os_info.caption), $($os_info.installdate), $($os_info.OSArchitecture), $($os_info.version), $($os_info.BuildNumber), $($os_info.servicepackmajorversion)")



