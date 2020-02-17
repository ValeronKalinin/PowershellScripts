function writetextblock {
Write-Host "-----------------------------------------------------------------------------------------------------------"
Write-Host "1    - СОЗДАТЬ ПОЛЬЗОВАТЕЛЕЙ"
Write-Host "2    - СОЗДАТЬ МЭЙЛБОКСЫ"
Write-Host "3    - СОЗДАТЬ ЗАПРОС НА ПЕРЕМЕЩЕНИЕ"
Write-Host "4    - СОЗДАТЬ КОНТАКТ И ПЕРЕАДРЕСАЦИЮ"
Write-Host "5    - ОСВОБОДИТЬ МЕСТО НА ДИСКЕ"
Write-Host "6    - ПРОВЕРИТЬ ЗАГРУЗКУ ПРОЦЕССОРА (ТЕСТИРУЕМ)" #ФУНКЦИЯ GETPROC
Write-Host "help - ИНСТРУКЦИЯ"
Write-Host "exit - ВЫХОД"
Write-Host "-----------------------------------------------------------------------------------------------------------"
}

function getproc{
$computername= Read-Host "Введите имя удаленного компьютера, например 'CDC-TERM-01'"
$getproc=gwmi Win32_PerfFormattedData_PerfProc_Process -Computername $computername|`
Sort-Object PercentProcessorTime -desc | Select-Object -first 10 | select name, PercentProcessorTime


foreach ($item in $getproc)
{
    
    $procent=$item.PercentProcessorTime
    if ($procent -gt 0)
    {
    $item=$item.name.Split("#")[0]+".exe"

    $item
    Get-WMIObject Win32_Process|?{$_.name -eq $item}|%{$_.getowner().user}
    $procent
   
    }

}}
#Сюда будет записана функция создания доменных учеток
function create_ad_users{



}

#Проверка кредов и проброс сессии до эксча
    function chkPss {

$exSrv="cdc-exch-08.sibintek.ru"
$triger=1
$CheckPssession=(Get-PSSession).ComputerName 
    
    if(!$CheckPssession) 
     {  
                     
                 Import-PSSession (New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$exSrv/PowerShell/ -Authentication Kerberos) 
                  
  
    }
  
  else {
  foreach ($item in $CheckPssession)
  {
    if([string]$item -eq $exSrv)
           
           {
                $triger=$item
                Write-Host $triger
                
           }

   
   

    if ($triger -notlike  $exSrv)
    {
                  Import-PSSession (New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://$exSrv/PowerShell/ -Authentication Kerberos) 
    }
  
 }
 }
  
 }


#Подсчет меэлбоксов и выбор наименее загруженных баз
    function Cmbx {
  if (!$CountMailboxes)  

    {
        cls   
        Write-Host "-----------------------------------------"
        Write-Host "Выбираем наименее загруженные базы. Ждите"
        #$CountMailboxes = Get-MailboxDatabase  -Status|where mounted -like true | where name -NotContains "DAGBase-10Gb-10 [RN TEMP]"| select -Property Name, Server, @{n="CountMailbox"; e={$((Get-mailbox -Database $_.Name -ResultSize unlimited).count)}} | sort Name | select -First 25
        $Global:CountMailboxes=Get-MailboxDatabase -Status| where  {$_.NAME -match  "DAGBase-\d{1,2}Gb-\d{1,2}$" -and $_.mounted -like $true}| select -Property Name, Server, @{n="CountMailbox"; e={$((Get-mailbox -Database $_.Name -ResultSize unlimited).count)}} | sort Name
   }  
    
    
   
                $Global:Temp1GB = ($CountMailboxes | Where-Object Name -like "DAGBase-1Gb*" | sort CountMailbox | select -First 1).name
                $Global:Temp4Gb = ($CountMailboxes | Where-Object Name -like "DAGBase-4Gb*" | sort CountMailbox | select -First 1).name
                $Global:Temp10Gb =($CountMailboxes | Where-Object Name -like "DAGBase-10Gb*"| sort CountMailbox | select -First 1).name
                $Global:Temp20Gb =($CountMailboxes | Where-Object Name -like "DAGBase-20Gb*"| sort CountMailbox | select -First 1).name

                               
                        #$Global:CountMailboxes, $Global:Temp1GB, $Global:Temp4Gb, $Global:Temp10Gb, $Global:Temp20Gb
                        #$Temp1GB, $Temp4Gb, $Temp10Gb, $Temp20Gb
#----------------------------------------------------------
#Выводим на экран базы данных с наименьшим кол-вом почтовых ящиков

        return $Global:CountMailboxes, $Global:Temp1GB, $Global:Temp4Gb, $Global:Temp10Gb, $Global:Temp20Gb
        }


#Перемещение мэйлбксов - нужно указывать переменную $MyInvocation >>>  mvreq ($MyInvocation)    
    function mvreq($MyInvocation){
    
#----------------------------------------------------------
#STATIC VARIABLES
#----------------------------------------------------------
$path     = Split-Path -parent $MyInvocation.MyCommand.Definition
$csvpath = $path + "\import_create_ad_users.csv"
$log  = $path + "\log\new_moverequest_users.log"
#$logerr = "C:\Scripts_create_ad_user\new_moverequest_users.err"
$date = Get-Date
    
chkPss
Cmbx

 $data=Import-CSV $csvpath  
       "----------------------------------------"| Out-File $log -append
       "Processing started (on " + $date + "): " | Out-File $log -append
       ForEach ($i in $data)
      
       {
      
		   If ($i.MailBoxSize -eq '1Gb' ) 
                {                   
                 New-MoveRequest -Identity $i.sAMAccountName.Trim() -TargetDatabase $Temp1Gb -Priority Highest 
		         "[LOG]`t Moving mailbox : $($i.sAMAccountName)" | Out-File $log -Append                             
                } 
                
		   If ($i.MailBoxSize -eq '4Gb' ) 
                {                   
                 New-MoveRequest -Identity $i.sAMAccountName.Trim() -TargetDatabase $Temp4Gb -Priority Highest
		         "[LOG]`t Moving mailbox : $($i.sAMAccountName)" | Out-File $log -Append
                 }
                
		   If ($i.MailBoxSize -eq '10Gb' ) 
                {                   
                 New-MoveRequest -Identity $i.sAMAccountName.Trim() -TargetDatabase $Temp10Gb -Priority Higher
		         "[LOG]`t Moving mailbox : $($i.sAMAccountName)" | Out-File $log -Append                                             
                }
           If ($i.MailBoxSize -eq '20Gb' ) 
                {                   
                 New-MoveRequest -Identity $i.sAMAccountName.Trim() -TargetDatabase $Temp20Gb -Priority Higher
		         "[LOG]`t Moving mailbox : $($i.sAMAccountName)" | Out-File $log -Append                                             
                }
       
       }

        ForEach ($i in $data)
      
       {
       $stat=Get-MoveRequest -Identity $i.sAMAccountName.Trim() | select displayname, status, PercentComplete

       if ($stat)
       {
       while ($stat.Status -notlike "Completed")

       {
        Get-MoveRequest|Get-MoveRequestStatistics |ft 
        $stat=Get-MoveRequest -Identity $i.sAMAccountName.Trim() | select  displayname,SourceDatabase, TargetDatabase, status, PercentComplete
        $percentcomplete=Get-MoveRequestStatistics -Identity $i.sAMAccountName.Trim() | select displayname, status, PercentComplete
        #Write-Host $inf
        Write-Host  $percentcomplete.DisplayName $percentcomplete.Status $percentcomplete.PercentComplete
        Start-Sleep -s 10
        cls
        
       }
       
        Write-Host $stat.DisplayName $stat.SourceDatabase $stat.TargetDatabase $stat.Status 
        $stat.DisplayName, $stat.SourceDatabase, $stat.TargetDatabase, $stat.Status | Out-File $log -Append  
        Remove-MoveRequest $i.sAMAccountName -Confirm:$false
       }
       
       }  
       Get-MoveRequest -MoveStatus completed|Remove-MoveRequest -Confirm:$false    

    
    }

#Функция создания почтовых контактов и установки переадресации нужно указывать переменную $MyInvocation >>>> MailCont($MyInvocation)
    function MailCont($MyInvocation){
$path     = Split-Path -parent $MyInvocation.MyCommand.Definition
chkPss

#Объявляем переменную списка юзеров
$Mail_Contacts = Import-Csv $path\import_create_ad_users.csv

$TargetOU="OU=Contacts,OU=SibUsers,DC=sibintek,DC=ru"



foreach ($Mail_Contact in $Mail_Contacts)

{
    
    $ExternalEmailAddress = $Mail_Contact.ExternalEmailAddress.Trim()
    $ExternalEmailAddress
    
    $domain=$ExternalEmailAddress.Split("@")[1]
    $domain=$domain.Trim()
    
    $Name=$Mail_Contact.sAMAccountName.Trim()
    $Name

    $DisplayName=Get-ADUser $name.Split("@")[0]

   
   
Switch ($domain) {


    rosneft.ru         {$DisplayName="РН - " + $DisplayName.name.ToString()}
    bashneft.ru        {$DisplayName="БН - " + $DisplayName.name.ToString()}
    sibintekinvest.com {$DisplayName="СИ - " + $DisplayName.name.ToString()}
    samara.sibintek.ru {$DisplayName="СМ - " + $DisplayName.name.ToString()}
    samng.ru           {$DisplayName="СН - " + $DisplayName.name.ToString()}
    udmurtneft.ru      {$DisplayName="УН - " + $DisplayName.name.ToString()}
    DEFAULT            {$DisplayName="РН - " + $DisplayName.name.ToString()}           
               
                }
   
   $DisplayName
   
    $TargetOU
    Write-Host " "
    
    new-mailcontact -DisplayName $DisplayName  -Name $DisplayName -Alias $Name.Split("@")[0] -ExternalEmailAddress $ExternalEmailAddress  -OrganizationalUnit $TargetOU
    set-mailbox -Identity $Name -ForwardingAddress $ExternalEmailAddress -DeliverToMailboxAndForward $true 
}
    
}

# Функция создания почтовых ящиков
    function Create_mailbox_users ($MyInvocation){
    
$path     = Split-Path -parent $MyInvocation.MyCommand.Definition
$newpath  = $path + "\import_create_ad_users.csv"
$log      = $path + "\log\create_mailbox_users.log"
$logerr   = $path + "\log\create_mailbox_users_err.log"
$date     = Get-Date
   
   Write-Host "STARTED SCRIPT`r`n"
  
   
    "Processing started (on " + $date + "): " | Out-File $log -append
  "--------------------------------------------" | Out-File $log -append
     
     
     Import-CSV $newpath | ForEach { If (!(Get-Mailbox $_.sAMAccountName.trim() -ErrorAction SilentlyContinue)) 
	    {
		   If ($_.MailBoxSize -eq '1Gb' ) 
                {                   
                 Enable-Mailbox -Identity $_.sAMAccountName.trim() -Database $Temp1GB -Alias $_.sAMAccountName.trim()
		         "[LOG]`t Creating mailbox : $($_.sAMAccountName)" | Out-File $log -append                              
                } 
                
		   If ($_.MailBoxSize -eq '4Gb' ) 
                {                   
                 Enable-Mailbox -Identity $_.sAMAccountName.trim() -Database $Temp4Gb -Alias $_.sAMAccountName.trim()
		         "[LOG]`t Creating mailbox : $($_.sAMAccountName)" | Out-File $log -append
                 }
                
		   If ($_.MailBoxSize -eq '10Gb' ) 
                {                   
                 Enable-Mailbox -Identity $_.sAMAccountName.trim() -Database $Temp10Gb -Alias $_.sAMAccountName.trim()
		         "[LOG]`t Creating mailbox : $($_.sAMAccountName)" | Out-File $log -append                                             
                }
           If ($_.MailBoxSize -eq '20Gb' ) 
                {                   
                 Enable-Mailbox -Identity $_.sAMAccountName.trim() -Database $Temp20Gb -Alias $_.sAMAccountName.trim()
		         "[LOG]`t Creating mailbox : $($_.sAMAccountName)" | Out-File $log -append                                             
                }
              } 
               Else
                   {
                    Write-Host "[ERROR]`Creating mailbox!"
                    "(on " + $date + "):  [ERROR]`t Creating mailbox : $($_.sAMAccountName)!" | Out-File $logerr -append  
    
    
    
                    }
        }
    Write-Host "STOPPED SCRIPT"
    }



$path     = Split-Path -parent $MyInvocation.MyCommand.Definition

cls
writetextblock
$in= Read-Host  "Введите число от 1-6, help или exit"

while ($in -notlike "exit")
{
if ($in -eq 1) {Invoke-Expression -Command $path\create_ad_users.ps1}
if ($in -eq 2) {
                    chkPss
                    Cmbx
                    Create_mailbox_users ($MyInvocation)

                }
if ($in -eq 3) {    chkPss
                    Cmbx
                    mvreq($MyInvocation)
               }
if ($in -eq 4) {
                    chkPss
                    Cmbx
                    MailCont($MyInvocation)

                }
if ($in -eq 5) {$remoteservername= Read-Host  "Введите имя удаленного компьютера, например 'CDC-TERM-01'"
                Invoke-Command -ComputerName $remoteservername -FilePath C:\Scripts\FreeSpaceMaker.ps1}
if ($in -eq 6) {getproc}

if ($in -eq "help") 

    {cls
    write-host 
    "    Для работы скрипта теперь используется только файл import_create_ad_users.csv` 
    Для выполнения команд  1 и 2 - формат файла остается прежним.`
    Для выполнения команды 3 - нужны только поля sAMAccountName и MailBoxSize `
    Для выполнения команды 4 - нужны только поля sAMAccountName и ExternalEmailAddress
    В файле эти поля уже есть, нужно просто заполнить.
    #
    На данный момент протестированны все функции. Есть косяк в вызове create_maibox_users.ps1 ` 
    Он работает, но выдает странный вывод на экран, я думаю все пофиксится когда скрипты переедут
    в функци" 
    
    
    
writetextblock
$in= Read-Host  "Введите число от 1-6, help или exit"

}

else
{

$in=$null
writetextblock
$in= Read-Host  "Введите число от 1-6, help или exit"

}
}