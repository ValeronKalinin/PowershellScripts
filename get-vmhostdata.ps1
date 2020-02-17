
#Запрос учетных данных и подключение к VC
if ($DCcred -eq $null) {
    $DCcred = Get-Credential -Message "Учетные данные для VC  с доменной авторизацией"
}

if ($SFcred -eq $null) {
    #$SFcred = Get-Credential -Message "Учетные данные для CLOUD"
}

if ($global:DefaultVIServers -eq $null) {
    Connect-VIServer -Credential $SFcred -Server cloud.orglot.office, cloud2.orglot.office
    #Connect-VIServer -Credential $DCcred -Server idf-vc.orglot.office, 8bus-vc.orglot.office, core-vc-ltt-01.orglot.office, sms-vc.orglot.office, board-vc.orglot.office, board-prod-vc.orglot.office, sas-vc.orglot.office, sap-vc.orglot.office, gate-test-vc.orglot.office
}

# Список Вцентров к которым есть подключение
$Vservers = $global:DefaultVIServers 
$Vservers.name

#Формируем нумерованную таблицу
$vstable = $null
$vstable = @()
[int]$i = 0

foreach ($vsitem in $Vservers.name) {
    $i++
    $myobj = New-Object -TypeName psobject 
    Add-Member -InputObject $myobj -MemberType NoteProperty -name "N" -Value $i
    Add-Member -InputObject $myobj -MemberType NoteProperty -name "VCenterServer" -Value $vsitem
  
    $vstable += $myobj

}
cls
$vstable = $vstable| sort N


#Запрос VC из которых необходимо собрать информацию

[array]$servers = $null#;$servers=@()
[int]$value = 1
cls
$vstable|ft
Write-Host "Введите имя сервера или "N" для выхода:"  #`n 
while ($value -ne "") {
    [int]$value = $null
    $value = Read-Host
    if ($value -gt 0) {
        $servers += $vstable[$value - 1].VCenterServer
    }
}
 
$servers = $servers|select -Unique 
$servers

$hosts = $null; $hosts = @()
foreach ($server in $servers) {
    $hosts += Get-VMHost -Server $server| select Name, ConnectionState, PowerState, NumCpu, CpuUsageMhz , CpuTotalMhz, MemoryUsageGB, MemoryTotalGB, @{n = "VCenter"; e = {$server}}
    }
$hosts


$list = $null
foreach ($h in $hosts) {
    $VCenter = $h.VCenter
    $mem = $h.MemoryTotalGB 
    $parent = $h.Parent
    [array]$list += Get-VMHostHardware -VMHost $h.Name |select VMHost , Model , SerialNumber, CpuModel, CpuCount, CpuCoreCountTotal, @{n = "MemoryTotalGB"; e = {$mem}}, @{n = "VCenter"; e = {$VCenter}}

}

[array]$hostlist = $null
foreach ($l in $list) {
    $serialnumber = $l.SerialNumber 
    $ILO = "ilo-" + $l.SerialNumber
    $disk = (Get-HPiLOStorageController -Server $ILO -Credential $DCcred).CONTROLLER.LOGICAL_DRIVE.PHYSICAL_DRIVE
    $disk = $disk | select MEDIA_TYPE, @{n = "Capacity"; e = { $_.MARKETING_CAPACITY.replace(" GB", "")}}, @{n = "Server"; e = {"$serialnumber"}}
    
    $props = @{
    
        SsdDisk           = ($disk|where MEDIA_TYPE -like "SSD" | measure -Property Capacity -Sum).sum
        HddDisk           = ($disk|where MEDIA_TYPE -like "HDD" | measure -Property Capacity -Sum).sum
        SerialNumber      = $l.SerialNumber
        Host              = $l.VMHost
        Model             = $l.Model
        CpuModel          = $l.CpuModel 
        MemoryTotalGB     = $l.MemoryTotalGB
        Group             = $l.Group
        CpuCoreCountTotal = $l.CpuCoreCountTotal
        CpuCount          = $l.CpuCount
        VCenter           = $l.VCenter
    }

    $hostlist += New-Object -TypeName psobject -Property $props
    #$hostlist| select *
    
}

$hostlist | select VCenter, host, serialnumber, model, CpuCount, CpuCoreCountTotal, CpuModel, MemoryTotalGB, HddDisk, SsdDisk | Out-GridView

 Get-Datastore |select Name ,ParentFolder, CapacityGB , FreeSpaceGB|where ParentFolder -NotLike "Local"|  sort name| Out-GridView

