
$cred=Get-Credential
$servers = Get-ADComputer -Filter {name -like "*1c-ms*" -and name -notlike "*MSSS*"} -Properties *
$computerslist=$null;$computerslist=@()
foreach ($server in $servers)
{

if (Test-Connection -ComputerName $server.DNSHostName -Count 1  -ErrorAction SilentlyContinue)
{
$server| select DNSHostName, OperatingSystem 
$computerslist+=$server
}
}

$computers=$computerslist.DNSHostName

foreach ($computer in $computers)

{
    invoke-command -ComputerName $computer -ErrorAction SilentlyContinue -ScriptBlock  { 
                                                           param ($computer   )

                                                            #$LogJournals = Get-Winevent  -ErrorAction SilentlyContinue  -listlog Application, Security, System |  Where-Object {($_.RecordCount -gt 10000)} | select Logname, FileSize, RecordCount, LogFilePath   
                                                            $LogJournals = Get-Winevent  -ErrorAction SilentlyContinue  -listlog *| select Logname, FileSize, RecordCount, LogFilePath   |  Where-Object {($_.RecordCount -ge 1)}
                                                            $obj=$null
                                                            $list=$nul;$list = @()
                                                            #$LogJournals
 
                                                             foreach ($LogJournal in $LogJournals) 

                                                            {

                                                            $ln=$LogJournal.LogName.ToString()

                                                            $date = (Get-Date).AddMonths(-1)

                                                            $log=Get-WinEvent -ErrorAction SilentlyContinue   -FilterHashtable @{ LogName=$ln ; StartTime=$date}
                                                            #количество записей в журнале
                                                            #$log.Count
                                                            #средний размер лога
                                                            #($LogJournal.FileSize/$LogJournal.RecordCount)


                                                            $MIDDLE_SIZE_1RECORD=($LogJournal.FileSize/$LogJournal.RecordCount)/1mb
                                                            $SIZE_MONTH=($log.count*($LogJournal.FileSize/$LogJournal.RecordCount))/1mb

                                                                       $props =@{
                                                                                Computername=$computer
                                                                                LOGNAME=$ln
                                                                                FILESIZE=$LogJournal.FileSize/1mb
                                                                                ALL_RECORDS_COUNT=$LogJournal.RecordCount                 
                                                                                MIDDLE_SIZE_1RECORD_MB=[Math]::Round($MIDDLE_SIZE_1RECORD, 5)
                                                                                RECORDS_PER_MONTH=$log.Count
                                                                                SIZE_MONTH_MB=[Math]::Round($SIZE_MONTH, 2)
                                                                                }
                                                                            $obj=New-Object -TypeName psobject -Property $props
                                                                            $list+=$obj | select  Computername, logname, FileSize, ALL_RECORDS_COUNT, MIDDLE_SIZE_1RECORD_MB,RECORDS_PER_MONTH, SIZE_MONTH_MB 
                                                            }

                                                            return  $list
                                                            } -Credential $cred -AsJob -ThrottleLimit 30 -JobName $computer
}