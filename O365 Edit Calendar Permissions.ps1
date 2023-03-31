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
        Add-MailboxFolderPermission -Identity $calendar -User $recievingUser -AccessRights PublishingEditor
        Add-MailboxFolderPermission -Identity $task -User $recievingUser -AccessRights PublishingEditor
    }

    Write-Host "All modifications for $owner have been completed"
}

Write-Host "All modifications complete"
