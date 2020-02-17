$erroractionpreference = "SilentlyContinue"
#Измененый кусок для 1й директории
$groups = (Get-Acl '\\orglot.office\Orglot\Договоры').access
$list = $null; $list = @()
foreach ($group in $groups) {
    #Отрезаем доменный префикс, с ним чет не заработало
    $groupacl = $group.IdentityReference -replace "ORGLOT\\", ""
    #Проверяем доменная ли группа
    if (Get-ADGroup $groupacl) {
        $groupmembers = Get-ADGroupMember $groupacl -Recursive 
        $props = @{
            group             = $group.IdentityReference
            AccessControlType = $group.AccessControlType
            rights            = $group.FileSystemRights
            #users=($groupmembers.name) -join ","
            users             = $groupmembers.name 
        }
        $obj = New-Object -TypeName psobject -Property $props
        $list += $obj
    }
          
}
#$list | Out-GridView
    
$ListCollums = =$null; $ListCollums = @()
foreach ($li in $list) {
    foreach ($user in $li.users) {
               
        $props = @{
            group             = $li.group
            AccessControlType = $li.AccessControlType
            rights            = $li.rights
            #users=($groupmembers.name) -join ","
            users             = $user
        }
        $obj1 = New-Object -TypeName psobject -Property $props
        $ListCollums += $obj1
    }
    
}

$ListCollums | select Users, group, AccessControlType, rights

#$list | export-csv -Path C:\Users\v.kalinin\Desktop\acl1111.csv -Encoding UTF8 -NoTypeInformation -Delimiter ";"
#выводм нужную группу $list[1].users.SamAccountName
#Ищем михайлову
#$list| where users -like "*Михайлова*"


#####################################
<#
#Тоже работает но не подробно
$groups=(Get-Acl '\\Core-SOFS-1.orglot.office\$1C-MSTS$\1C-DBs-Config').access
$rightsm=$groups  | where { $_.FileSystemRights -like "*Mod*" -and $_.AccessControlType -like "*allow*"}| select IdentityReference,FileSystemRights,IsInherited
$rightsr=$groups  | where { $_.FileSystemRights -like "*Read*" -and $_.AccessControlType -like "*allow*"}| select IdentityReference,FileSystemRights,IsInherited
$rightsf=$groups  | where { $_.FileSystemRights -like "*full*" -and $_.AccessControlType -like "*allow*"}| select IdentityReference,FileSystemRights, IsInherited

$rightsm 
$rightsr
$rightsf

#>