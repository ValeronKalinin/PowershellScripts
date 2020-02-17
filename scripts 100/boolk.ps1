$csv= Import-Csv -Path 'C:\Users\v.kalinin\Desktop\WorkScripts\scripts 100\PM-Exp.csv' -Encoding UTF8 -Delimiter ";"
$csv
foreach ($cs in $csv)
{
 #"`n"|Out-File -FilePath "C:\Users\v.kalinin\Desktop\WorkScripts\scripts 100\pm-ilo.txt" -Append 
"Title: " + $cs.title |Out-File -FilePath "C:\Users\v.kalinin\Desktop\WorkScripts\scripts 100\pm-ilo.txt" -Append 
"URL: " + $cs.url   |Out-File -FilePath "C:\Users\v.kalinin\Desktop\WorkScripts\scripts 100\pm-ilo.txt" -Append 
"Password: " + $cs.password  |Out-File -FilePath "C:\Users\v.kalinin\Desktop\WorkScripts\scripts 100\pm-ilo.txt" -Append 
"Default Login: " + $cs.login  |Out-File -FilePath "C:\Users\v.kalinin\Desktop\WorkScripts\scripts 100\pm-ilo.txt" -Append 
"Default Pass: " + $cs.'Default pass'  |Out-File -FilePath "C:\Users\v.kalinin\Desktop\WorkScripts\scripts 100\pm-ilo.txt" -Append 
"Tag: " + $cs.tag |Out-File -FilePath "C:\Users\v.kalinin\Desktop\WorkScripts\scripts 100\pm-ilo.txt" -Append 
"`n"|Out-File -FilePath "C:\Users\v.kalinin\Desktop\WorkScripts\scripts 100\pm-ilo.txt" -Append 
}