$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://core-ex-1.orglot.office/powershell -Authentication Kerberos -Credential $UserCredential
Import-PSSession $Session
$cred = Get-Credential

Send-MailMessage -Body "test" -From unicusweb@elt-poisk.com -To "rokes@list.ru" -SmtpServer "mail.stoloto.ru" -Port 25 -Credential $cred -Subject "test"