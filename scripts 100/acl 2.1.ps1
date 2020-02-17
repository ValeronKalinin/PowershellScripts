$erroractionpreference="SilentlyContinue"
#Измененый кусок для 1й директории
$groups=(Get-Acl '\\orglot.office\orglot\Управления\Управление информационных технологий\Для внутреннего пользования').access
$list=$null; $list=@()
$obj=$null
#$groups | ft
foreach ($group in $groups)

{
        if ($group.IdentityReference -notlike  "*ORGLOT*" )
        #Встроенные пользователи и группы
        {
        Write-Host $group.IdentityReference -ForegroundColor Green 
        $props =@{
                    group=$group.IdentityReference
                    AccessControlType=$group.AccessControlType
                    rights=$group.FileSystemRights
                    #users=($groupmembers.name) -join ","
                    users=$group.IdentityReference
                    }
                $obj=New-Object -TypeName psobject -Property $props
                $list+=$obj 
        }
        else {
        #Доменные пользователи и группы
        $groupacl=$group.IdentityReference -replace "ORGLOT\\",""
            if (Get-aduser $groupacl ) #Если пользователь
            {
            Write-Host $group.IdentityReference -ForegroundColor Cyan
            $props =@{
                    group=$group.IdentityReference
                    AccessControlType=$group.AccessControlType
                    rights=$group.FileSystemRights
                    #users=($groupmembers.name) -join ","
                    users=(get-aduser $groupacl).name
                    }
                $obj=New-Object -TypeName psobject -Property $props
                $list+=$obj 
            }


            if (Get-ADGroup $groupacl)# если группа
            {      
            Write-Host $group.IdentityReference -ForegroundColor Red
            $groupmembers= Get-ADGroupMember $groupacl -Recursive 
                $props =@{
                    group=$group.IdentityReference 
                    AccessControlType=$group.AccessControlType
                    rights=$group.FileSystemRights
                    #users=($groupmembers.name) -join ","
                    users=$groupmembers.name

                    }
                $obj=New-Object -TypeName psobject -Property $props
                $list+=$obj
            }
        }

}

    $ListCollums=$null; $ListCollums=@()
    foreach ($li in $list)

    {
        foreach ($user in $li.users)
        {
               
               $props =@{
                    group=$li.group
                    AccessControlType=$li.AccessControlType
                    rights=$li.rights
                    #users=($groupmembers.name) -join ","
                    users=$user
                    }
                $obj1=New-Object -TypeName psobject -Property $props
               $ListCollums+=$obj1
        }
    }
    $ListCollums | select Users,group, AccessControlType, rights

    $ListCollums| Out-GridView