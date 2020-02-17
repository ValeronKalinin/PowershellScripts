$erroractionpreference="SilentlyContinue"
$primaryzonenames =Import-Csv -Path C:\Users\v.kalinin\Desktop\zones.csv
$nsservers =Import-Csv -Path C:\Users\v.kalinin\Desktop\ns.csv
$exist=$null; $exist=@()
foreach ($primaryzonename in $primaryzonenames)

{

$childzonename=$primaryzonename.name.Split(".") | select -First 1

$zn=$primaryzonename.name.Split(".") | select -First 5 |select -Last 4
$zn =$zn -join "."


#get-DnsServerZoneDelegation -ComputerName core-dc-1.orglot.office -Name $zn   -ChildZoneName $childzonename
    foreach ($nsserver in $nsservers)
    {
    
    Add-DnsServerZoneDelegation -ErrorAction SilentlyContinue -ComputerName core-dc-1.orglot.office -Name $zn -ChildZoneName $childzonename  -IPAddress $nsserver.IPAdressess -NameServer $nsserver.NSServers -WhatIf
    }
}

<#
if (!(Get-DnsServerZoneDelegation  -ComputerName core-dc-1.orglot.office -Name $zn -ChildZoneName $childzonename))
{
#$n=($childzonename +"."+ $zn)
$exist+=($childzonename +"."+ $zn)
}

}
#>