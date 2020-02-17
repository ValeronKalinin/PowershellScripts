#Запрос учетных данных и подключение к VC
<#
if ($DCcred -eq $null) {
    $DCcred = Get-Credential -Message "Учетные данные для VC  с доменной авторизацией"
}
#>
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



$hosts=Get-VMHost| sort name

foreach ($h in $hosts)
{
$h
$table+=($h|Get-VMHostHBA -Type FibreChannel | where model -EQ "2600 Series 16Gb Fibre Channel to PCI Express HBA"|select @{n="hostname";e={$h.name}}, PortWorldWideName)
}

$table| sort hostname

$table2=$null
foreach ($h in $hosts)
{
$h
#$h|Get-VMHostHba| select *
$table2+=($h|Get-VMHostHBA | select *  |select VMHost , @{N="WWN";E={"{0:X}" -f $_.PortWorldWideName}})
}

$table2| sort hostname