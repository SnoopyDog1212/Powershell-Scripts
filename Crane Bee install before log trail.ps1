## Install Script for Cranebee (currently working, just not Verbose enough)

# It might be worth clearing/deleting the program data folder before installing/fixing up the uninstall script and making it reinstall
$RealModulesFolder = Join-Path $modulesFolder -ChildPath "module"
$Arguments = @"
/S /netzlizenz /licpath="$($LicensePath.LocalPath)"
"@
$Process = Start-Process -Wait $InstallerFile -ArgumentList $Arguments -Passthru
Write-Host "exitcode: $($Process.exitcode)"
# I removed the module install cause it seemed to be too large of a point of failure and it would require us to manually update them 

# Old Args
#$Arguments = @"
#/S /netzlizenz /licpath="$($LicensePath.LocalPath)" /diskinstall /offlinepath="$RealModulesFolder"
#"@

# I want it be dynamically showing the logs from C:\ProgramData\CRANIMAX\CRANEbee\Logs\CB.beeAdmin20220513 (yearmonthday)
# This log will show you what the second installer is actually doing

$ExitTime = (get-date).addseconds(1800)

do{
    $PathExists = test-path "C:\Program Files\CRANIMAX\CRANEbee\ApplicationData\CRANEbee.exe"
    Sleep -s 1
}
until($PathExists -or (get-date) -gt $ExitTime)
