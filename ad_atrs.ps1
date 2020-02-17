$users=import-csv C:\Users\v.kalinin\Desktop\WorkScripts\05.07.2017\import_create_ad_users.csv
#$Users = Import-Csv .\Documents\О-4175.csv
$massiv=$null; $massiv=@()
foreach ($user in  $users )
{

    #Set-ADUser $user.sAMAccountName   -extensionAttribute1 $user.bday
    #Set-ADUser $user.sAMAccountName -Replace @{extensionAttribute1 = $user.bday}
    
    Set-ADUser $user.sAMAccountName -DisplayName  $user.displayName
    Set-ADUser $user.sAMAccountName -Replace @{DisplayName = $user.displayName}
    
    Set-ADUser $user.sAMAccountName -department  $user.Department
    Set-ADUser $user.sAMAccountName -Replace @{department = $user.Department} 

    Set-ADUser $user.sAMAccountName -title $user.Title
    Set-ADUser $user.sAMAccountName -Replace @{title = $user.Title} 
    
    Set-ADUser $user.sAMAccountName -StreetAddress   $user.StreetAddress
    Set-ADUser $user.sAMAccountName -Replace @{StreetAddress  = $user.StreetAddress}
     
    Set-ADUser $user.sAMAccountName -City  $user.City
    Set-ADUser $user.sAMAccountName -Replace @{city = $user.City}

    Set-ADUser $user.sAMAccountName -State  $user.State
    Set-ADUser $user.sAMAccountName -Replace @{State = $user.State}

    Set-ADUser $user.sAMAccountName -Postalcode  $user.PostalCode
    Set-ADUser $user.sAMAccountName -Replace @{Postalcode = $user.PostalCode}
    
    Set-ADUser $user.sAMAccountName -Company   $user.Company
    Set-ADUser $user.sAMAccountName -Replace @{Company  = $user.Company}
    
    Set-ADUser $user.sAMAccountName -telephoneNumber   $user.Phone
    Set-ADUser $user.sAMAccountName -Replace @{telephoneNumber  = $user.Phone}
    
    Set-ADUser $user.sAMAccountName -MobilePhone  $user.Mobile
    Set-ADUser $user.sAMAccountName -Replace @{MobilePhone = $user.Mobile}
    
    $usermn=$user.Manager
    
    if ($user.Manager -like $Null)
    {
    $usermname=$Null
    }
    else {
    $usermname=(Get-ADUser -Filter{displayName -like  $usermn} -Properties *)
    $usermname=$usermname.SamAccountName
   
     Set-ADUser $user.sAMAccountName -Manager  $usermname
     Set-ADUser $user.sAMAccountName -Replace @{Manager = $usermname}
    
    }

    
    #Генератор пароля
    $Password=$null
    $numberchars=0..9 | % {$_.ToString()}
    $lochars = [char]'a' .. [char]'z' | % {[char]$_}
    $hichars = [char]'A' .. [char]'Z' | % {[char]$_}
    $punctchars = [char[]](33,35,36,37,38,64,63)

    $PASS= Get-Random -InputObject @($hichars + $lochars + $numberchars + $punctchars) -Count 6
    $PASS+=Get-Random -InputObject @($numberchars) -Count 1
    $PASS+=Get-Random -InputObject @($punctchars) -Count 1
    $PASS = -join ($PASS | sort {Get-Random})
    #Сброс пароля
     Set-ADAccountPassword $user.sAMAccountName  -NewPassword (ConvertTo-SecureString $PASS -AsPlainText -force) -Reset -PassThru | Set-ADuser -ChangePasswordAtLogon $false  
    
    #Перенос в нужную ОУ
     $dn=(get-aduser -Identity $user.sAMAccountName).DistinguishedName 
     move-ADObject -Identity $dn  -TargetPath $user.TargetOU
     set-aduser $user.sAMAccountName -Enabled $true 
     
     $state =(get-aduser $user.sAMAccountName -Properties * |select  -Property displayName,sAMAccountName,@{n="newpassword";e={$PASS}}, Enabled,CanonicalName, Department,Title,StreetAddress,City,state,PostalCode,Company,Phone,Mobile,Manager  )
     $state | Export-Csv .\Desktop\WorkScripts\05.07.2017\1cusers.csv -Encoding UTF8 -NoTypeInformation -Append
     
$massiv +=$state   
     
}
$massiv | ft *
#(get-acl C:\users\v.kalinin\).Access |? {$_.FileSystemRights -like "*Full*"}
#Get-ADUser -Filter * -SearchBase "OU=Employees,OU=CloudUsers,DC=clouddc,DC=ru" -Properties * |select  -Property name, department, title, StreetAddress, City, State, Postalcode, Company,telephoneNumber, MobilePhone, Manager , extensionAttribute1| Export-Csv .\Documents\users.csv -Encoding UTF8