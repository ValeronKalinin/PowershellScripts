$leases=$null; $leases=@()
$servers=Get-DhcpServerInDC

foreach ($server in $servers)
{
$leases+=Get-DhcpServerv4Scope –ComputerName $server.DnsName | % {Get-DhcpServerv4Lease -ScopeId $_.ScopeId -ComputerName $server.DnsName}

}
$date=Get-Date -UFormat %d.%m
$path="C:\Users\v.kalinin\Desktop\"+$date+"_dhcp_pools.csv"
$leases | Export-Csv -Path $path -Encoding UTF8 -NoTypeInformation