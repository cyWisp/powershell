
Option Explicit

Dim objDSE, strDN, objContainer, objChild, sCommand, WshShell

Set objDSE = GetObject("LDAP://rootDSE")
strDN = "OU=Domain Controllers," & objDSE.Get("defaultNamingContext")

Set objContainer = GetObject("LDAP://" & strDN)

sCommand = "%COMSPEC% /C " 
Set WshShell = WScript.CreateObject("WScript.Shell")

objContainer.Filter = Array("Computer")
For Each objChild In objContainer
    if Ucase(mid(objChild.Name,4)) <> "USMP10DC01" then
        WshShell.Run(sCommand & "if exist \\" & _ 
           mid(objChild.Name,4) & "\Sysvol repadmin /syncall " _ 
           & mid(objChild.Name,4) & _ 
           ".usmed.com dc=usmed,dc=com /force")
    end if
Next