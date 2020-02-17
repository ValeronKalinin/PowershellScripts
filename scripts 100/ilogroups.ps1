$cred=Get-Credential
#-Username $cred.UserName -Password $cred.Password
[string]$ilooperator = "2,4,3,6"  # Набор выдаваемых прав
[string]$dn3 = "CN=ILO-BB.ADMIN,OU=iLo,OU=SecurityGroups,OU=Groups,OU=.CompanyRoot,DC=orglot,DC=office" 
[string]$sid3 = "S-1-5-21-4054586374-1217062678-3094406088-1200033"

$ipaddresses=Import-Csv -Path "C:\Users\v.kalinin\Desktop\ip.csv"  
foreach ($ipaddr in $ipaddresses)
{
Set-HPiLOSchemalessDirectory -Server  $ipaddr.ip.trim()  -GroupAccount "Yes" -Credential $cred -group3name $dn3 -Group3sid $sid3 -Group3Priv $ilooperator -DisableCertificateAuthentication
}


<#
$cred=Get-Credential

$list=import-csv -Path C:\Users\v.kalinin\Desktop\harius.csv
foreach($l in $list)
{
$gr=Get-HPiLODirectory -Server  ILO-CZJ82700NY.orglot.office -Credential $cred -DisableCertificateAuthentication | select DIR_GRPACCT*
$l.ip
$gr -match "ilo-bb"
}
#>