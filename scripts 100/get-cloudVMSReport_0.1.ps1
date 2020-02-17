 $path= "C:\Users\v.kalinin\Desktop\vms.csv" #Укажи путь C:\Новая папка\новая папка 2\не порно видео\
 
 Connect-VIServer  -Server cloud.orglot.office, cloud2.orglot.office -User "stl-mon@vsphere.local" -Password "KTSzFk"
 $servers=$global:DefaultVIServers

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
            $IPs=$null

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

             foreach ($ip in (VMware.VimAutomation.Core\Get-VMGuest -VM $vm).IPAddress){
                
                $IPs= $IPs+ " " + $ip.tostring() 
            }

            try {
                $sn = (Get-VMHostHardware -VMHost $h.Name -ErrorAction SilentlyContinue).SerialNumber 
            }
            catch { }

            $params = @{
                IP           = $IPs
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
                ProvisionedSpaceGB  =[System.Math]::Round( $vm.ProvisionedSpaceGB,2)
            }
            $vm.Name
            $result += New-Object -TypeName psobject -Property $params
           
        }
    }
}


$result | select vCenter,Hostname, Serialnumber, Vmname ,PowerState , NumCpu, MemoryGB, ProvisionedSpaceGB,vlan, IP,tagD,tagE, Notes | Export-Csv -Path $path -Encoding UTF8 -NoTypeInformation -Delimiter ";"
