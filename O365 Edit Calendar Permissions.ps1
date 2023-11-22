##This logs you into the O365 Server for changes
Connect-ExchangeOnline

#Who needs access:
#for multiple users you can seperate them with commas ie ('user','user2')
$giveAccessTo = @('user1@domain.com','user2@domain.com')

#Who they need access to:
$calendarOwners = @('user3@domain.com','user4@domain.com')

#All Write-Host commands are built to display information in the console while running the script
Write-Host "Attemping " ($giveAccessTo.Count * $calendarOwners.Count * 2) " changes"

foreach($owner in $calendarOwners){
    Write-Host "Starting modifications for $owner"
    $giveAccessTo[0]

    #for Keogh, it is important to update both Calendar and Tasks permissions as they use both
    $calendar = $owner + ":\Calendar"
    $task = $owner + ":\Tasks"

    foreach($recievingUser in $giveAccessTo){
        ##The try and catch blocks are designed to resolve the below errors without the script crashing out
        ##Add-MailboxFolderPermission: |Microsoft.Exchange.Management.StoreTasks.UserAlreadyExistsInPermissionEntryException|An existing permission entry was found for user: user.
        try {
            Add-MailboxFolderPermission -Identity $calendar -User $recievingUser -AccessRights PublishingEditor -ErrorAction Stop
        }
        catch {
            Set-MailboxFolderPermission -Identity $calendar -User $recievingUser -AccessRights PublishingEditor 
        }
        try {
            Add-MailboxFolderPermission -Identity $task -User $recievingUser -AccessRights PublishingEditor -ErrorAction Stop
            }
        catch {
            Set-MailboxFolderPermission -Identity $task -User $recievingUser -AccessRights PublishingEditor
            }
    }

    Write-Host "All modifications for $owner have been completed"
}

Write-Host "All modifications complete"


#Misc Commands I find may be useful to run individually in certain cases
## Check permissions to Calendar
## Get-MailboxFolderPermission -Identity user@domain.com:\Calendar 

## Create list of all users permissions to Mailboxes
#Get-Mailbox -resultsize unlimited | Get-MailboxPermission | Select Identity, User, Deny, AccessRights, IsInherited| Export-Csv -Path "c:\temp\mailboxpermissions.csv" -NoTypeInformation

#Fixing hidden groups 
##Set-UnifiedGroup -Identity "Cortana Corridor" -HiddenFromExchangeClientsEnabled:$false
##Set-UnifiedGroup -Identity "Cortana Corridor" -HiddenFromAddressListsEnabled:$false
