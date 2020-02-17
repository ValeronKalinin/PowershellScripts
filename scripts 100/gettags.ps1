if ($DCcred -eq $null) {
    $DCcred = Get-Credential -Message "Учетные данные для VC  с доменной авторизацией"
}

if ($SFcred -eq $null) {
    $SFcred = Get-Credential -Message "Учетные данные для CLOUD"
}

if ($global:DefaultVIServers -eq $null) {
    Connect-VIServer -Credential $DCcred -Server core-vc-ltt-01.orglot.office
    #Connect-VIServer -Credential $SFcred -Server  cloud.orglot.office , cloud2.orglot.office
   # Connect-VIServer -Credential $DCcred -Server idf-vc.orglot.office, 8bus-vc.orglot.office, core-vc-ltt-01.orglot.office, sms-vc.orglot.office, board-vc.orglot.office, board-prod-vc.orglot.office, sas-vc.orglot.office, sap-vc.orglot.office, gate-test-vc.orglot.office
}
$vcs=$global:DefaultVIServers.name

foreach ($vc in $vcs){

$vms = get-vm -Server $vc

$tags = @()
$data = @()
foreach ($vm in $vms) {
    Remove-Variable res
    $res = New-Object psobject
    $tags = $vm | Get-TagAssignment
    $category = Get-TagCategory
    foreach ($cat in $category) {
        $catname = $cat.name
        $res | Add-Member -MemberType NoteProperty -Name $catname -Value "" -Force
    }
    $res | Add-Member -MemberType NoteProperty -Name "VM Name" -Value $vm.name
    $res | Add-Member -MemberType NoteProperty -Name "Folder" -Value $vm.Folder
    foreach ($tag in $tags.tag) {
        $cat = $tag.category.name
        #$res.$cat = $tag.name
        $res | Add-Member -MemberType NoteProperty -Name $cat -Value $tag.name -Force

    }
    $data += $res
}

$path="C:\Users\v.kalinin\Desktop\Vcenter_$vc.csv"
$data|select "VM Name",Folder,Product,Environment,Service,Department,"The responsible person"| export-csv -Path $path -Encoding UTF8 -Delimiter ";" -NoTypeInformation
}
#Disconnect-VIServer 

