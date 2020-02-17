#$UserCredential = Get-Credential
#$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://core-ex-1.orglot.office/powershell -Authentication Kerberos -Credential $UserCredential
#Import-PSSession $Session
$emails =$null ; $emails=@()
#New-MailboxExportRequest -Mailbox $user.ToString() -FilePath  $path.ToString() -BadItemLimit unlimited 

$pst=get-childitem -Path "\\core-fs-1\SIM-SIM\pst\DELTA" -File
$pst=$pst.name
$adusers= $pst -replace ".pst" ,""
$adusers

foreach ($aduser in $adusers )

{


$emails+=(get-aduser $aduser -Properties mail)



}

foreach ($email in $emails)

{
$path= "\\core-fs-1\SIM-SIM\pst\DELTA\" + $email.samaccountname +".pst"
$file=(get-item -Path $path).FullName
New-MailboximportRequest -Mailbox $email.samaccountname -FilePath  $file -BadItemLimit unlimited  
$email.samaccountname

}

#New-MailboximportRequest -Mailbox a.pogodin -FilePath  \\core-fs-2\TempSIM\a.pogodin.pst -BadItemLimit unlimited 
#New-MailboximportRequest -Mailbox i.kisil -FilePath  \\core-fs-2\TempSIM\i.kisil.pst -BadItemLimit unlimited 
#New-MailboximportRequest -Mailbox j.volkova -FilePath  \\core-fs-2\TempSIM\y.volkova.pst -BadItemLimit unlimited 
#New-MailboximportRequest -Mailbox v.vanteev -FilePath  \\core-fs-1\sim-sim\pst\v.vanteev.pst -BadItemLimit unlimited 