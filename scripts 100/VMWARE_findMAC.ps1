Get-PowerCLIConfiguration
Set-PowerCLIConfiguration -InvalidCertificateAction ignore -confirm:$false

$Cloudcred=Get-Credential
$cred=Get-Credential
Connect-VIServer -Credential $Cloudcred -Server cloud.orglot.office, cloud2.orglot.office
Connect-VIServer -Credential ($cred) -Server idf-vc.orglot.office, board-vc.orglot.office, board-prod-vc.orglot.office, sas-vc.orglot.office 


$vms=Get-vm
$vms.count
foreach ($vm in $vms) 

{
$mac=$null
$mac=($vm|Get-NetworkAdapter | where MacAddress -Like "*4:08:7a"| select *)

if ($mac -ne $null){

$vm
$mac

    }
}