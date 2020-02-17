
#$cred=Get-Credential
#Connect-VIServer -Credential $cred -Server cloud.orglot.office, cloud2.orglot.office
#Connect-VIServer -Credential (Get-Credential) -Server idf-vc.orglot.office,8bus-vc.orglot.office,core-vc-ltt-01.orglot.office,sms-vc.orglot.office, board-vc.orglot.office, board-prod-vc.orglot.office, sas-vc.orglot.office,sap-vc.orglot.office,gate-test-vc.orglot.office


#$hosts= Get-Datacenter | select -First 2| Get-VMHost
#$hosts = Get-VMHost

#foreach ($h in $hosts)
#{
#$hsn=(get-esxcli -VMHost $h).hardware.platform.get().SerialNumber
#$ilo=$("ILO-"+$hsn).ToString()
#Test-Connection -ComputerName $ilo -Count 1
#$h | select name, @{n="serialNumber"; e={$hsn}}, @{n="ILO"; e={"ILO-"+$hsn}}, @{n="PING"; e={(Test-Connection -ComputerName $("ILO-"+$hsn) -Count 1).time }}
#$ping=Test-Connection -ComputerName $("ILO-"+$hsn) -Count 1

#}

<# 
$cred=Get-Credential
Connect-VIServer -Credential $cred -Server 8bus-vc.orglot.office
Get-Datacenter

$hosts = get-datacenter NC-DC| Get-VMHost 
$hosts| select Name, CpuUsageMhz, CpuTotalMhz,MemoryUsageGB, MemoryTotalGB | Out-GridView

datastores=Get-Datastore |select Datacenter, Name, FreeSpaceGB, CapacityGB | Out-GridView

#>
#datastores=Get-Datastore |select Datacenter, Name, FreeSpaceGB, CapacityGB | Out-GridView





$hosts=get-vmhost 

foreach ($h in $hosts)
{
$pathcpu="C:\Users\v.kalinin\Desktop\06.02\"+$h.Name+"_CPU"+".csv"
$pathMem="C:\Users\v.kalinin\Desktop\06.02\"+$h.Name+"_MEM"+".csv"
$pathDisk="C:\Users\v.kalinin\Desktop\06.02\"+$h.Name+"_DISK"+".csv"
$h| get-stat -Cpu | where Timestamp -gt (get-date).AddMonths(-3)|select MetricId ,Timestamp,Value,Unit| export-csv -Path $pathcpu -NoTypeInformation -Delimiter ";"
$h| get-stat -Memory | where Timestamp -gt (get-date).AddMonths(-3)|select MetricId ,Timestamp,Value,Unit| export-csv -Path $pathMem -NoTypeInformation -Delimiter ";"
$h| get-stat -Disk| where Timestamp -gt (get-date).AddMonths(-3)|select MetricId ,Timestamp,Value,Unit| export-csv -Path $pathDisk -NoTypeInformation -Delimiter ";"

}Consolas, 'Lucida Console', monospace