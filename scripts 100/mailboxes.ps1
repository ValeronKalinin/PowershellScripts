$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://core-ex-1.orglot.office/powershell -Authentication Kerberos -Credential $UserCredential
Import-PSSession $Session

$d = (Get-Date).AddHours(-2)
#$mailboxes=Get-ExchangeServer | % {Get-MailboxStatistics -Server $_.name }   | select DisplayName,TotalItemSize, LastLogonTime | Sort-Object TotalItemSize -Descending
$log=Get-ExchangeServer | % {Get-MessageTrackingLog -server $_.name -Start $d   -Recipients "moderate@stoloto.ru"  |select EventID,timestamp, Source,Sender,Recipients, MessageSubject, MessageId |sort timestamp}
#Search-Mailbox -Identity moderate -SearchQuery 'attachment:"*.uue"  received:24/07/2018'-EstimateResultOnly  #-TargetMailbox "valery.kalinin@stoloto.ru" -TargetFolder "Восстановленное" 

№add-MailboxFolderPermission -identity "s.perminov:\календарь" -User sergey.lykov@stoloto.ru -AccessRights Reviewer