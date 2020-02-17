
$Servers= find-hpilo "10.200.201", "10.200.204", "10.200.205","10.200.206", "10.200.207", "10.200.224", "10.200.225", "10.200.226", "10.200.227"
$res=@()
$select=@()
foreach ($Server in $servers){
#Remove-Variable obj
#$obj=New-Object psobject

$iml=Get-HPiLOIML -Server $server -Username hw -Password pqhV=88!0qnm1pkk -DisableCertificateAuthentication

$firmvares=$null
$firmvares=(Get-HPiLOFirmwareInfo -Server $Server  -Username hw -Password pqhV=88!0qnm1pkk -DisableCertificateAuthentication).FirmwareInfo

$Critevents=$iml.event | where SEVERITY -like Critical

foreach($Critevent in $Critevents){
Remove-Variable obj
$obj=New-Object psobject
$obj| Add-Member -MemberType NoteProperty -Name "Name" -Value $server.HOSTNAME
$obj| Add-Member -MemberType NoteProperty -Name "SN" -Value $server.SerialNumber
$obj| Add-Member -MemberType NoteProperty -Name "CLASS" -Value $Critevent.CLASS 
$obj| Add-Member -MemberType NoteProperty -Name "DESCRIPTION" -Value $Critevent.DESCRIPTION
$obj| Add-Member -MemberType NoteProperty -Name "INITIAL_UPDATE" -Value $Critevent.INITIAL_UPDATE
$obj| Add-Member -MemberType NoteProperty -Name "LAST_UPDATE" -Value $Critevent.LAST_UPDATE

$obj| Add-Member -MemberType NoteProperty -Name "System ROM" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "Redundant System ROM" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "Intelligent Provisioning" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "Intelligent Platform Abstraction Data" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "System Programmable Logic Device" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "Server Platform Services (SPS) Firmware" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "Smart HBA H240" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "Dynamic Smart Array B140i Controller" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "HP Ethernet 1Gb 2-port 361i Adapter" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "Power Management Controller Firmware" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "Power Management Controller FW Bootloader" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "SAS Programmable Logic Device" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "HPE Smart Storage Battery 1 Firmware" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "Smart Array P440ar Controller" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "HPE Ethernet 1Gb 4-port 331i Adapter - NIC" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "HP Ethernet 1Gb 4-port 331FLR Adapter" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "HP Smart Storage Battery 1 Firmware" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "HP Ethernet 1Gb 4-port 331i Adapter #2" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "HP FlexFabric 10Gb 2-port 533FLR-T Adapter" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "System ROM Bootblock" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "Power Management Controller Firmware Bootloader" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "Smart Array P420i Controller" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "Smart Array P420 Controller" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "Broadcom NetXtreme Gigabit Ethernet #3" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "HP StorageWorks 82Q 8Gb PCI-e Dual Port FC HBA" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "HP Ethernet 1Gb 4-port 331i Adapter" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "Smart Array P244br Controller" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "HP FlexFabric 20Gb 2-port 630FLB Adapter" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "HP QMH2672 16Gb FC HBA" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "iLO 5" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "Innovation Engine (IE) Firmware" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "Embedded Video Controller" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "HPE Eth 10Gb 2p 562T Adptr" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "HPE Smart Array P408i-a SR Gen10" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "NVMe Backplane 1 Firmware" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "NVMe Backplane 2 Firmware" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "NVMe Backplane 3 Firmware" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "NVMe Backplane 4 Firmware" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "NVMe Backplane 5 Firmware" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "HPE Smart Array P204i-b SR Gen10" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "HP FlexFabric 10Gb 2-port 536FLB Adapter" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "HPE QMH2672 16Gb 2P FC HBA - FC" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "HP Ethernet 1Gb 4-port 331T Adapter" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "HP FlexFabric 20Gb 2-port 650FLB Adapter" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "HP QMH2672 16Gb FC HBA for BladeSystem c-Class" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "HPE SN1100Q 16Gb 2P FC HBA" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "HPE Eth 10/25Gb 2p 640FLR-SFP28 Adptr" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "Network Controller" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "HPE Eth 10Gb 2p 535FLR-T Adptr" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "HPE Eth 10/25Gb 2p 631FLR-SFP28 Adptr" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "HPE Smart Array P816i-a SR Gen10" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "HPE Smart Storage Energy Pack 1 Firmware" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "HPE Smart Array E208i-a SR Gen10" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "HPE Eth 10Gb 2p 562FLR-T Adptr" -Value "NONE"
$obj| Add-Member -MemberType NoteProperty -Name "HP Ethernet 10Gb 2-port 561FLR-T Adapter" -Value "NONE"


foreach ($firmvare in $firmvares) {

$f=$null
$f=$firmvare.FIRMWARE_NAME
$obj.$f=$firmvare.FIRMWARE_VERSION 

}

}
$server.HOSTNAME 
$Server.SerialNumber
#$obj
#Start-Sleep "3"
if($obj -ne $null )
{
$res+=$obj
}
#$select+=$obj.psobject.properties.name
#$select=$select| select -Unique
#$res
}



$res| export-csv -Path C:\Users\v.kalinin\Desktop\IloErr1.csv -NoTypeInformation -Encoding UTF8