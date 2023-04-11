##This logs you into the O365 Server for changes
Connect-ExchangeOnline

#Setup Array's of the users you want to change
$giveAccessTo = @('user1@domain.com','user2@domain.com')
$calendarOwners = @('user1@domain.com','user2@domain.com')

Write-Host "Attemping " ($giveAccessTo.Count * $calendarOwners.Count * 2) " changes"

foreach($owner in $calendarOwners){
    Write-Host "Starting modifications for $owner"

    $calendar = $owner + ":\Calendar"
    $task = $owner + ":\Tasks"

    foreach($recievingUser in $giveAccessTo){
        ##It may be worth making the catch block more specific incase of a misspelled email error
        ##Add-MailboxFolderPermission: |Microsoft.Exchange.Management.StoreTasks.UserAlreadyExistsInPermissionEntryException|An existing permission entry was found for user: user.
        try {
            Add-MailboxFolderPermission -Identity $calendar -User $recievingUser -AccessRights PublishingEditor
        }
        catch {
            Set-MailboxFolderPermission -Identity $calendar -User $recievingUser -AccessRights PublishingEditor
        }
        try {
            Add-MailboxFolderPermission -Identity $task -User $recievingUser -AccessRights PublishingEditor
            }
        catch {
            Set-MailboxFolderPermission -Identity $task -User $recievingUser -AccessRights PublishingEditor
            }
    }

    Write-Host "All modifications for $owner have been completed"
}

Write-Host "All modifications complete"
