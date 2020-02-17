#Запрос учетных данных и подключение к VC
if ($DCcred -eq $null) {
    $DCcred = Get-Credential -Message "Учетные данные для VC  с доменной авторизацией"
}

if ($SFcred -eq $null) {
    $SFcred = Get-Credential -Message "Учетные данные для CLOUD"
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
$vstable = $vstable | sort N


#Запрос VC из которых необходимо собрать информацию

[array]$servers = $null#;$servers=@()
[int]$value = 1
cls
$vstable | ft
Write-Host "Введите имя сервера или "N" для выхода:"  #`n 
while ($value -ne "") {
    [int]$value = $null
    $value = Read-Host
    if ($value -gt 0) {
        $servers += $vstable[$value - 1].VCenterServer
    }
}
 
$servers = $servers | select -Unique 
$servers
$result = @()

foreach ($server in $servers) {
    $hosts = Get-VMHost -Server $server
    foreach ($h in $hosts) {
        $vms = Get-VM -Location $h.Name
        foreach ($vm in $vms) {
            $tag=(VMware.VimAutomation.Core\Get-TagAssignment -Entity $vm).tag
            foreach($t in $tag){
                if($t.category -like "Department/The responsible person")
                {

                $TagDepartment=$t.name + " / " + $t.Description
                
                }
                 if($t.category -like "Environment")
                {

                $TagEnv=$t.name + " / " + $t.Description
                
                }
                
                }
            
            $vlan = @()
            $vlans=$null

            $nics = (VMware.VimAutomation.Core\Get-VMGuest -VM $vm).Nics.Device        
            try {
                foreach ($nic in $nics) {
                    if ((Get-VDPortgroup -NetworkAdapter $nic).VlanConfiguration.vlanid -ne $null)
                    { $vlan += ((Get-VDPortgroup -NetworkAdapter $nic).VlanConfiguration.vlanid).tostring()}
                }
            }
            catch { } 

            if ((VMware.VimAutomation.Core\Get-VirtualPortGroup -VM $vm).vlanid -ne $null) {
                $vlan += ((VMware.VimAutomation.Core\Get-VirtualPortGroup -VM $vm).vlanid).tostring()
            }

            foreach ($v in $vlan){
                
                $vlans= $vlans+ " " + $v.tostring() 
            }

            try {
                $sn = (Get-VMHostHardware -VMHost $h.Name -ErrorAction SilentlyContinue).SerialNumber 
            }
            catch { }




            $params = @{
                IP           = (VMware.VimAutomation.Core\Get-VMGuest -VM $vm).Nics.IPAddress
                vCenter      = $server
                Hostname     = $h.Name
                Serialnumber = $sn
                Vmname       = $vm.Name
                vlan         = $vlans
                tagD         = $TagDepartment
                tagE         = $TagEnv
                Notes        = $vm.Notes
                PowerState   = $vm.PowerState
                NumCpu       = $vm.NumCpu
                MemoryGB     = $vm.MemoryGB
                ProvisionedSpaceGB  =$vm.ProvisionedSpaceGB
            }
            $vm.Name
            $result += New-Object -TypeName psobject -Property $params
           
        }
    }
}


$result | select vCenter,Hostname, Serialnumber, Vmname ,PowerState , NumCpu, MemoryGB, ProvisionedSpaceGB,vlan, IP,tagD,tagE, Notes | Export-Csv -Path C:\Users\v.kalinin\Desktop\vms.csv -Encoding UTF8 -NoTypeInformation -Delimiter ";"
