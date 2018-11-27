﻿Get-MailboxStatistics | where {$_.Database -eq "E:\DATABASES\USM_USERS\USM_USERS.edb" -and $_.LastLogonTime -lt (get-date).addDays(-90) -and $_.ObjectClass -eq "Mailbox"} | sort-object lastlogontime | ft DisplayName > C:\users\administrator.usmed\desktop\inactiveMB.txt