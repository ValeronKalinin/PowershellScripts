$nmsrvs=$null; $nmsrvs=@()
$computername = "core-dc-1"

$primaryzonename = "210.10.in-addr.arpa"

$childzonename = "55","56"

$ipadresses =  "10.210.32.16",
                  "10.210.32.17"

$nameservers = "ns4.stoloto.su", 
                  "ns5.stoloto.su"
# Если грузить из цсв – этот вайл - ненужен
$I=0;
while ($I -lt $ipadresses.count) 
    {

    $props =@{
                    nameserver=$nameservers[$i]
                    ip=$ipadresses[$i]}
                           
        $obj=New-Object -TypeName psobject -Property $props
        $nmsrvs+=$obj
        $I++

    } 

   foreach ( $item in $childzonename)

   {
   foreach ($nmsrv in $nmsrvs)

   {
   Add-DnsServerZoneDelegation -ComputerName $computername -name $primaryzonename -ChildZoneName $item -IPAddress $nmsrv.ip -NameServer $nmsrv.nameserver -WhatIf
   }
   
   
   }

