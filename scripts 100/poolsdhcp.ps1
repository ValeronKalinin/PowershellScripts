$dns=$null; $dns=@()
$servers = Get-ADComputer -SearchBase "OU=Servers,OU=Computers,OU=.CompanyRoot,DC=orglot,DC=office" -Filter {enabled -eq "true"}

foreach ($server in $servers)
{

$dns+=Get-DnsServerResourceRecord  -Name $server.Name -ZoneName "orglot.office" -RRType A| select *
$dns+=Get-DnsServerResourceRecord  -Name $server.Name -ZoneName "stoloto.ru" -RRType A
$dns+=Get-DnsServerResourceRecord  -Name $server.Name -ZoneName "elt-poisk.com" -RRType A

}