#Application,System,
$LogJournals= Get-Winevent -ErrorAction   SilentlyContinue   -listlog * |  Where-Object {($_.RecordCount -gt 1000)} | select Logname, FileSize, RecordCount, LogFilePath   
$list=$null; $list=@()
$obj=$null
#$LogJournals
 
 
 foreach ($LogJournal in $LogJournals) 

{

$ln=$LogJournal.LogName.ToString()

$date = (Get-Date).AddMonths(-1)

$log=Get-WinEvent -ErrorAction   SilentlyContinue  -FilterHashtable @{ LogName=$ln ; StartTime=$date}
#количество записей в журнале
$log.Count
#средний размер лога
#($LogJournal.FileSize/$LogJournal.RecordCount)


$MIDDLE_SIZE_1RECORD=($LogJournal.FileSize/$LogJournal.RecordCount)/1mb
$SIZE_MONTH=($log.count*($LogJournal.FileSize/$LogJournal.RecordCount))/1mb

           $props =@{
                    LOGNAME=$ln
                    FILESIZE=$LogJournal.FileSize/1mb
                    ALL_RECORDS_COUNT=$LogJournal.RecordCount                 
                    MIDDLE_SIZE_1RECORD_MB=[Math]::Round($MIDDLE_SIZE_1RECORD, 5)
                    RECORDS_PER_MONTH=$log.Count
                    SIZE_MONTH_MB=[Math]::Round($SIZE_MONTH, 2)
                    }
                $obj=New-Object -TypeName psobject -Property $props
                $list+=$obj 


}

$list| select  logname, FileSize, ALL_RECORDS_COUNT, MIDDLE_SIZE_1RECORD_MB,RECORDS_PER_MONTH, SIZE_MONTH_MB | ft


#$log | Out-File -FilePath C:\123\1.xml