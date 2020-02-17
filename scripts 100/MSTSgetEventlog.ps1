$cred=Get-Credential 

$log=$null
$dta=$null;$dta2=@()

#$dates=get-date("25.07.18 18:43:00" )
#$datef=get-date("25.07.18 18:46:00" )

$dates=(get-date).AddDays(-3)
$datef=get-date

$servers="1c-msts-1.orglot.office","1c-msts-2.orglot.office"
foreach ($srv in $servers)

{
$LogJournals = Get-Winevent -ErrorAction   SilentlyContinue  -ComputerName $srv -Credential $cred  -listlog *terminalservices* |  Where-Object {($_.RecordCount -ge 1)}
#Get-Winevent   -listlog * |  Where-Object {($_.RecordCount -ge 1)}
# Выборка сообщений Warning и Error не старше часа
foreach ($LogJournal in $LogJournals) 

{
             
    $ln=$LogJournal.LogName.ToString()
    $log+=(Get-WinEvent -ErrorAction   SilentlyContinue -ComputerName $srv -Credential $cred -FilterHashtable @{ LogName=$ln;  <#id=20482; #> StartTime=$dates ; endTime=$datef ;level=1,2 }  )
  
}

#$log2 | select TimeCreated , Id,  LevelDisplayName, Message    |sort TimeCreated | where message -like "*shapir*"| export-csv -Path C:\Users\v.kalinin\Desktop\Помоище\logs\2.csv -Encoding UTF8 -NoTypeInformation
$LogJournals = Get-Winevent -ErrorAction   SilentlyContinue  -ComputerName $srv -Credential $cred  -listlog * |  Where-Object {($_.RecordCount -ge 1)}

foreach ($LogJournal in $LogJournals) 

{

$ln=$LogJournal.LogName.ToString()
$dta+=(Get-WinEvent -ErrorAction   SilentlyContinue -ComputerName $srv -Credential $cred -FilterHashtable @{ LogName=$ln; <#id=308036006, 6005 ,5016,4016,5312,5317,8000,8001,8006,8007#>;level=1,2;StartTime=$dates ; endTime=$datef })
}
}
$log| sort TimeCreated | select  TimeCreated ,MachineName, Id, Message #| where message -like "*shapiro*" #|Out-GridView
$dta|sort TimeCreated  | select  TimeCreated ,MachineName, Id, Message  |where id -NotLike "256" |Out-GridView