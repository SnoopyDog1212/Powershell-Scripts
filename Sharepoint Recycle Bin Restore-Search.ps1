#To install the required module
Install-Module -Name PnP.PowerShell

#To connected to the site
Connect-PnPOnline -Url "https://company.sharepoint.com/sites/siteName" -DeviceLogin -LaunchBrowser

#Search for and list all files (you could change the "? DirName" to any other property to sort by that instead)
Get-PnPRecycleBinItem | Select-Object -Property Title, ItemType, Size, Itemstate, DirName, DeletedByName, DeletedDate | ? DirName -Like '*sites/Files/General/Folder A/*'-and DeletedByName -Like 'John Smith' | fl

#Create a variable of all items that you want to restore (You have to change the DirName here once again)
#$items = Get-PnPRecycleBinItem | ? -Property DirName -Like '*sites/Files/General/Folder A/Folder B*'

#Use the above variable to restore each individual item
#foreach($item in $items) {Restore-PnpRecycleBinItem -Identity $item -Force}