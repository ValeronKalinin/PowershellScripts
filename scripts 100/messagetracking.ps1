#$UserCredential = Get-Credential
#function Connect ($UserCredential){


#$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://core-ex-1.orglot.office/powershell -Authentication Kerberos -Credential $UserCredential
#Import-PSSession $Session

#}


class MTLog
{
    #Properties
    [string] $recipient
    [string] $Sender
    [DateTime] $Datestart


    #constructor
   # MTLog ([string] $recipient,[string] $Sender,[System.DateTime] $Datestart)

   # {
    
    
    
   # }
    #Method
    GetMessageTracking([string] $recipient, [string] $Sender,[DateTime] $Datestart)
    {
   (Get-ExchangeServer | % {Get-MessageTrackingLog -server $_.name -Start $datestart  -Recipients $recipient -Sender $Sender  -ResultSize unlimited})
   Get-ExchangeServer
   Write-Host "1"$Datestart $recipient $Sender
   Write-Host $this.Datestart $this.recipient $this.Sender


  
    }

}


$mt= New-Object -type MTlog
$mt.GetMessageTracking("valery.kalinin@stoloto.ru","demid.gulenok@stoloto.ru" ,(get-date).AddDays(-12))




#$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://core-ex-1.orglot.office/powershell -Authentication Kerberos -Credential $UserCredential
#Import-PSSession $Session
#Get-MailboxDatabaseCopyStatus *
#$mtl2=(Get-ExchangeServer | % {Get-MessageTrackingLog -server $_.name -Start (get-date).AddDays(-4)  -Recipients "v@stoloto.ru"  -ResultSize unlimited})
#$ivan=Get-ExchangeServer | % {Get-MessageTrackingLog -server $_.name -Start (get-date).AddHours(-1)  -Recipients "anna.frolova@stoloto.ru"  -ResultSize unlimited}
#$mtl1=Get-ExchangeServer | %{Get-MessageTrackingLog -server $_.name -Start "09/10/2018 00:00:00" -sender "albatrostours@gpsinter.net"   }
#-MessageSubject "[Jira ITHD-5099]  Watch the on-demand sessions from Tableau Conference Europe 2018 and see where we’re heading to next year" -Recipients "valery.kalinin@stoloto.ru"| where eventid -like "receive" |select EventId,timestamp, Source,Sender,Recipients, MessageSubject, MessageId 
#-MessageId "2b1f90fcab4a84c67678cdaca47f4420@www.smartreading.ru"