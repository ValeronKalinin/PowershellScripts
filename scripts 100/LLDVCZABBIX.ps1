$p1="gate-prod-vc.orglot.office"
$p2="zabbix_vmware"
$p3="jcHNZBrf7"

#param($p1,$p2,$p3)

Connect-VIServer  -Server $p1 -User $p2 -Password $p3

$hosts=Get-vmHost| select name, @{n="HostUUID";e={$_.ExtensionData.hardware.systeminfo.uuid}}

@{"data"=
    
    foreach ($h in $hosts){
        @{'{#HV.NAME}' =$h.name
          '{#HV.UUID}' =$h.HostUUID
          '{#VCNAME}'  =$p1
        }
    
    }

}|ConvertTo-Json 