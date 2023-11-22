##Connects to exchange online
Connect-ExchangeOnline

## Mailbox we need to add SendOnBehalf permissions to
$mailboxToGrantPermissionsOf = "service@cornerstoneflooring.net"

## An array of all users who should have access
## the names are formatted as their AD usernames
## You can add more with additional commas and names in single quotes
$usersToGrantAccessTo = @('jcoizza','kevin','llopez','travis','clark', 'jorge', 'melanie')

## This will grant send on behalf of access to all included users
Set-Mailbox $mailboxToGrantPermissionsOf -GrantSendOnBehalfTo $usersToGrantAccessTo

## Lists out the current users who have access in a neat little list
Write-Host "Users who now currently have access:"
$output = (Get-Mailbox -ResultSize Unlimited -Identity $mailboxToGrantPermissionsOf | Select-Object -ExpandProperty GrantSendOnBehalfTo)
foreach($user in $output){
    Write-Host $user
}
