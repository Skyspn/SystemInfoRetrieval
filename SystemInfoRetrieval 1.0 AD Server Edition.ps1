<#
Author: Sky Sparnaaij
1.0 : This version is a branch of the SystemInfoRetrieval 2.1 AD Edition.
#It recieves all of the computers hardware through your entire company and puts them in a text file. Handy for inventory time.

#>




New-Item C:\S1772023KY.txt
#goes to AD to find each and every computer and places them into txt file
Get-ADComputer -Filter {Name -Like 'Fill in own computer prefix'} -SearchBase "Fill in own workstation OU" | Select-Object -expandproperty name | Out-File  "C:\S1772023KY.txt"
#goes looking what computers are in that file
$computerss = Get-Content -Path C:\S1772023KY.txt

New-Item -Path C:\ComputerInfo -ItemType Directory
#goes into a loop for each computer in that txt file 
foreach ($Departmentcomputer in $computerss ){

Test-Connection -ComputerName $Departmentcomputer -Quiet -ErrorAction SilentlyContinue

New-Item -path C:\ComputerInfo\Computer-$Departmentcomputer.txt

#Hardware info
Write-Host "PROCESSOR&GRAPHICS-CARD:" -ForegroundColor Yellow 
$CPU = Invoke-Command -ComputerName $Departmentcomputer -ScriptBlock {Get-CimInstance -ClassName Win32_Processor}
$Video = Invoke-Command -ComputerName $Departmentcomputer -ScriptBlock {Get-WmiObject win32_VideoController | Format-Table Description}
Write-Host "RAM:" -ForegroundColor Yellow 
$Ram = Invoke-Command -ComputerName $Departmentcomputer -ScriptBlock {Get-WmiObject win32_PhysicalMemory | Format-Table Manufacturer, Model, Tag, FormFactor, Speed}
#Write-Host "DISK:"-ForegroundColor Yellow
$DISK = Invoke-Command -ComputerName $Departmentcomputer -ScriptBlock {Get-CimInstance -ClassName Win32_LogicalDisk}
Write-Host "DISK&OPERATING-SYSTEM-INFO:" -ForegroundColor Yellow 
$OS = Invoke-Command -ComputerName $Departmentcomputer -ScriptBlock {Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -Property SerialNumber, Version}
Write-Host "IP_ADDRESS&MAC_ADDRESS:" -ForegroundColor Yellow
$ADDRESSES = Invoke-Command -ComputerName $Departmentcomputer -ScriptBlock {Get-WmiObject win32_networkadapterconfiguration | Format-Table description, IPAddress, macaddress}
Write-Host "TPM:" -ForegroundColor Yellow
$TPM = Invoke-Command -ComputerName $Departmentcomputer -ScriptBlock {Get-WmiObject -Namespace root/cimv2/security/microsofttpm -Class Win32_TPM | Format-Table SpecVersion}
Write-Host "USER LOGGED IN:" -ForegroundColor Yellow
$UserLoggedIn = Invoke-Command -ComputerName $Departmentcomputer -ScriptBlock {Get-CimInstance -ClassName Win32_ComputerSystem -Property UserName | Format-table Name, UserName}
Write-Host "BIOS INFO:" -ForegroundColor Yellow
$Bios = Invoke-Command -ComputerName $Departmentcomputer -ScriptBlock {Get-ComputerInfo -Property *BIOS* | Format-Table BiosFirmwareType, BiosManufacturer, BiosName, BiosSeralNumber, BiosVersion}
Write-Host "LOGON" -ForegroundColor Yellow
$logon = Get-ADComputer $Departmentcomputer -Properties * | Format-Table lastlogondate

#outputs computer info into txt file
'CPU & Graphics card:' | Out-File -FilePath C:\ComputerInfo\Computer-$Departmentcomputer.txt -Append
$CPU | Out-File -FilePath C:\ComputerInfo\Computer-$Departmentcomputer.txt -Append
$Video | Out-File -FilePath C:\ComputerInfo\Computer-$Departmentcomputer.txt -Append
'Ram:' | Out-File -FilePath C:\ComputerInfo\Computer-$Departmentcomputer.txt -Append
$Ram | Out-File -FilePath C:\ComputerInfo\Computer-$Departmentcomputer.txt -Append
'Disk & OS:' | Out-File -FilePath C:\ComputerInfo\Computer-$Departmentcomputer.txt -Append
$DISK | Out-File -FilePath C:\ComputerInfo\Computer-$Departmentcomputer.txt -Append
$OS | Out-File -FilePath C:\ComputerInfo\Computer-$Departmentcomputer.txt -Append
'Mac & IP addresses:' | Out-File -FilePath C:\ComputerInfo\Computer-$Departmentcomputer.txt -Append
$ADDRESSES | Out-File -FilePath C:\ComputerInfo\Computer-$Departmentcomputer.txt -Append
'TPM:' | Out-File -FilePath C:\ComputerInfo\Computer-$Departmentcomputer.txt -Append
$TPM | Out-File -FilePath C:\ComputerInfo\Computer-$Departmentcomputer.txt -Append
'User logged in:' | Out-File -FilePath C:\ComputerInfo\Computer-$Departmentcomputer.txt -Append
$UserLoggedIn | Out-File -FilePath C:\ComputerInfo\Computer-$Departmentcomputer.txt -Append
'Bios:' | Out-File -FilePath C:\ComputerInfo\Computer-$Departmentcomputer.txt -Append
$Bios | Out-File -FilePath C:\ComputerInfo\Computer-$Departmentcomputer.txt -Append
'Last Loggon:' | Out-File -FilePath C:\ComputerInfo\Computer-$Departmentcomputer.txt -Append
$logon | Out-File -FilePath C:\ComputerInfo\Computer-$Departmentcomputer.txt -Append

Remove-Item C:\S1772023KY.txt
}