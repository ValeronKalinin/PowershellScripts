#Запрос учетных данных и подключение к VC
if ($DCcred -eq $null) {
    $DCcred = Get-Credential -Message "Учетные данные для VC  с доменной авторизацией"
}

if ($SFcred -eq $null) {
    #$SFcred = Get-Credential -Message "Учетные данные для CLOUD"
}

if ($global:DefaultVIServers -eq $null) {
    #Connect-VIServer -Credential $SFcred -Server cloud.orglot.office, cloud2.orglot.office
    Connect-VIServer -Credential $DCcred -Server board-prod-vc.orglot.office
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
$vstable = $vstable| sort N


#Запрос VC из которых необходимо собрать информацию

[array]$servers = $null#;$servers=@()
[int]$value = 1
cls
$vstable|ft
Write-Host "Введите имя сервера или "N" для выхода:"  #`n 
while ($value -ne "") {
    [int]$value = $null
    $value = Read-Host
    if ($value -gt 0) {
        $servers += $vstable[$value - 1].VCenterServer
    }
}
 
$servers = $servers|select -Unique 
$servers
$vm=Get-VMHost -Server $servers| get-vm -Server $_
foreach($v in $vm)
{
Get-NetworkAdapter -VM $v.name
}