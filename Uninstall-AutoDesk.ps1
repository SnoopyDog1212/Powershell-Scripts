#Find software year so the script can choose the proper autodesk uninstall method
#Uninstall method changes based on release year
#Todo: Add logic to account for additional software that is installed along with certain Autodesk Programs (Such as Recap Pro installing ReCap Photo)
#Todo: Add percentage to the Write-Progress that are used
$ImmyAutodeskProductName = $SoftwareName.Substring(0,$SoftwareName.Length-4)
$AutodeskShortenedProductName = $ImmyAutodeskProductName.Substring(9,$ImmyAutodeskProductName.Length-9)
$ImmyAutodeskYear = $SoftwareName.Substring($SoftwareName.Length-4)
Write-Progress "Checking uninstall method for Version: $ImmyAutodeskProductName Year: $ImmyAutodeskYear"

#Autodesk 2022+ uninstall
if($ImmyAutodeskYear -gt 2021)
{
    Write-Progress "Detected Autodesk ODIS uninstall method"
    #ODIS uninstall method: (https://knowledge.autodesk.com/search-result/caas/CloudHelp/cloudhelp/ENU/Autodesk-Installation-Basic-ODIS/files/ODIS-silent-install-htm.html)

    Invoke-ImmyCommand{
        #Searching for apps installed using new ODIS method
        $AutodeskOdisDirectories = Get-ChildItem -Path C:\ProgramData\Autodesk\ODIS\metadata -Force -ErrorAction SilentlyContinue
        Write-Host "Found Directories: " $AutodeskOdisDirectories
        foreach($directory in $AutodeskOdisDirectories)
        {
            #Searching through the XML files to find the Release and software name of each installed ODIS software
            $XMLPath = "C:\ProgramData\Autodesk\ODIS\metadata\" + $directory + "\bundleManifest.xml"
            Write-Host "Checking: $XMLPath"
            [xml]$xmlElm = Get-Content -Path $XMLPath -ErrorAction SilentlyContinue
            $XMLRelease = $xmlElm.Bundle.Identity.Release
            $XMLDisplayName = $xmlElm.Bundle.Identity.DisplayName

            Write-Host "$XMLRelease $XMLDisplayName"

            #Verifying that the specific ODIS software matches what is expected
            if($XMLRelease -eq $using:ImmyAutodeskYear -and ("*$using:ImmyAutodeskProductName*" -like "*$XMLDisplayName*" -or "*$XMLDisplayName*" -like "*$using:ImmyAutodeskProductName*"))
            {
                Write-Progress "Matching software found, running uninstall of $XMLPath"
        
                #Running new ODIS uninstall method
                Start-Process "C:\Program Files\Autodesk\AdODIS\V1\Installer.exe" -Wait -ArgumentList "-i uninstall -q -m $XMLPath"
                If(!(Test-Path $XMLPath))
                {
                    Write-Progress "Uninstall of $XMLDisplayName completed"
                } else
                {
                    Write-Warning "Uninstall of $XMLDisplayName failed. Please reboot the machine and attempt again."
                }
            } 
        }
    }
    Write-Progress "All required uninstalls have been attempted"
}

#Autodesk 2021 and below uninstall 
elseif($ImmyAutodeskYear -lt 2022)
{
    Write-Progress "Detected Autodesk legacy uninstall method"
    #This script finds the product codes for each product and uninstalls them
    #https://knowledge.autodesk.com/support/autocad/learn-explore/caas/sfdcarticles/sfdcarticles/How-to-Uninstall-Autodesk-Products-Silently-Using-Batch-Scripts.html#:~:text=Using%20%22Run%20as%20Administrator%22%2C,if%20it%20uninstalls%20as%20intended.

    $BaseAutodeskRegPath = "HKLM:\SOFTWARE\Autodesk\UPI2\"
    $AutoDeskReg = (Invoke-ImmyCommand{Get-ChildItem -Path $using:BaseAutodeskRegPath})

    #Searching through each registry key and adding its product code to $AutoDeskRegEntries if it matches what is expected
    foreach($entry in $AutoDeskReg)
    {
        $RegPath = $BaseAutodeskRegPath + $entry.PSChildName

        $AutoDeskRegEntries += Invoke-ImmyCommand{

            #Getting the Product Code and Release of each Registry key
            $EntryProductCode = (Get-ItemProperty -Path "$using:RegPath").ProductCode
            $EntryProductYear = (Get-ItemProperty -Path "$using:RegPath").Release
        
            if(((Get-ItemProperty -Path "$using:RegPath").ProductName) -like "*$using:AutodeskShortenedProductName*" -and $EntryProductYear -eq $using:ImmyAutodeskYear)
            {
                Write-Progress "Found autodesk componet"
                Write-Host "Product Name:"  ((Get-ItemProperty -Path "$using:RegPath").ProductName)
                Write-Host "Product Year: $EntryProductYear"
                Return $EntryProductCode.split('{').split('}')
            } 
        }
    }

    #Removes null entries from $AutoDeskRegEntries
    $AutoDeskRegEntries = $AutoDeskRegEntries.Split('',[System.StringSplitOptions]::RemoveEmptyEntries)
    Write-Host "AutoDesk components found: " $AutoDeskRegEntries

    #Using misexec to uninstall each found product code in $AutoDeskRegEntries
    foreach ($ProductCode in $AutoDeskRegEntries)
    {
        Write-Progress "Uninstalling ProductCode: $ProductCode"

        $Arguments = @"
            /c msiexec /X {$ProductCode} /qn /noreboot REBOOT=REALLYSUPPRESS 
"@
        #Removed Log tail as it was generating MASSIVE logs from the multiple uninstalls that run with certain programs
        #Start-ProcessWithLogTail cmd -ArgumentList $Arguments -LogFilePath $InstallerLogFile
        Invoke-ImmyCommand -Timeout 600 {Start-Process cmd -ArgumentList $using:Arguments -Wait}
        
        Write-Host "Uninstall Completed."
    }
}

else
{
    Write-Warning "Cannot determine uninstall Method. Ensure software is named correctly."
}
