#this script will add an alias for the specified user

#asks for the username and new alias that should be
#created
$user = read-host "User "
$useralias = read-host "New Alias "

#converts the input to string
#$user = $user.toString
#$userAlias = $userAlias.toString

#sets the new alias for the specified user
Set-Mailbox $user -EmailAddresses @{add=$userAlias}

