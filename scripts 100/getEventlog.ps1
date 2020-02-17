$cred=Get-Credential 

$log=$null
$dta=$null;$dta2=@()

$dates=(get-date).AddHours(-2)
$datef=get-date

$servers="Core-fs-2"
foreach ($srv in $servers)

{
$LogJournals = Get-Winevent -ErrorAction   SilentlyContinue  -ComputerName $srv -Credential $cred  -listlog *terminalservices* |  Where-Object {($_.RecordCount -ge 1)}
#Get-Winevent   -listlog * |  Where-Object {($_.RecordCount -ge 1)}
# Выборка сообщений Warning и Error не старше часа
foreach ($LogJournal in $LogJournals) 

{
             
    $ln=$LogJournal.LogName.ToString()
    $log+=(Get-WinEvent -ErrorAction   SilentlyContinue -ComputerName $srv -Credential $cred -FilterHashtable @{ LogName=$ln;  <#id=20482; #> StartTime=$dates ; endTime=$datef ;level=1,2 }  )
    #$log
}

#$log2 | select TimeCreated , Id,  LevelDisplayName, Message    |sort TimeCreated | where message -like "*shapir*"| export-csv -Path C:\Users\v.kalinin\Desktop\Помоище\logs\2.csv -Encoding UTF8 -NoTypeInformation
$LogJournals = Get-Winevent -ErrorAction   SilentlyContinue  -ComputerName $srv -Credential $cred  -listlog * |  Where-Object {($_.RecordCount -ge 1)}

foreach ($LogJournal in $LogJournals) 

{

$ln=$LogJournal.LogName.ToString()
$dta+=(Get-WinEvent -ErrorAction   SilentlyContinue -ComputerName $srv -Credential $cred -FilterHashtable @{ LogName=$ln;StartTime=$dates ; endTime=$datef;level=1,2  })
}
}
$log| sort TimeCreated | select  TimeCreated ,MachineName, Id, Message |Out-GridView
$dta|sort TimeCreated  | select  TimeCreated ,MachineName, Id, Message |Out-GridView