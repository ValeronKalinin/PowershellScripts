$servers=Import-Csv -Path 'C:\Users\v.kalinin\Desktop\WorkScripts\scripts 100\prtg.csv'
$sourceid="44383"
$groupid="43688"

foreach ($server in $servers)

{
$name=$server.name.trim()
$fqdn="ILO-"+$name+".orglot.office"
$name
$fqdn
Get-Device -id $sourceid| Clone-Object $groupid $name $fqdn
Get-Device $name | Resume-Object 
}


#Get-Object -id 44621 | Set-ObjectProperty Tags $tags