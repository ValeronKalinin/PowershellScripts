<#
.SYNOPSIS

Set iLO management module settings to comply internal standards of JSC STOLOTO

.DESCRIPTION

Set iLO management module to comply internal standards of JSC STOLOTO.

Examine these variables and change if necessary:
[string]$folderpath
[string]$mail
#>

[string]$folderpath = "C:\123"
#[string]$folderpath = Read-Host "`nEnter local folder where *.cer file will be located. Remember, file must have name $servername.cer"
[string]$mail = "valery.kalinin@stoloto.ru"
#[string]$mail = Read-Host "Enter your e-mail, new password for ILO will be sent to you as memo. Please add it to https://pm.stoloto.ru/core-pm.html"
[string]$dn1 = "CN=ITD.LeadAdministrators,OU=ADAdministrative,OU=SecurityGroups,OU=Groups,OU=.CompanyRoot,DC=orglot,DC=office"
[string]$sid1 = "S-1-5-21-4054586374-1217062678-3094406088-1174668"
[string]$dn2 = "CN=ITD.HDAdministrators,OU=ADAdministrative,OU=SecurityGroups,OU=Groups,OU=.CompanyRoot,DC=orglot,DC=office"
[string]$sid2 = "S-1-5-21-4054586374-1217062678-3094406088-1178116"
#[string]$dn3 = "CN=iLo.BKM.Operator,OU=BKM,OU=iLo,OU=SecurityGroups,OU=Groups,OU=.CompanyRoot,DC=orglot,DC=office"
#[string]$sid3 = "S-1-5-21-4054586374-1217062678-3094406088-1198870"
[string]$ilolic = "3QPXQ-YYR76-5MQS5-BBSDL-QY4GH"
[string]$iloadmin = "1,2,3,4,5,6"
[string]$ilooperator = "2,4,6"
[string]$forest = "orglot.office"

#[string]$servername = Read-Host -Prompt "Enter planned server NETBIOS name."

if (!(Test-Path $folderpath)) {
    Write-Host "`nNo export folder found! Press ENTER to try again or Ctrl+C to exit, then RTFM" -ForegroundColor Red
    Read-Host
}

$check = $false
while ($check -ne $true) {
    [string]$ip = Read-Host -Prompt "`nEnter an IP-address of iLO management interface"
    $ip=$ip.Trim()
    if ($ip -eq ($([ipaddress]$ip).IPAddressToString)) {
        try {
            $servername = (Find-HPiLO $ip -wa 0 -ea 0).SerialNumber.trim()
        }
        catch {}
        if ($? -eq $true) {
            $check = $true
        }
        else {
            Write-Host "`nNo server found! Press ENTER to try again or Ctrl+C to exit" -ForegroundColor Red
        }
    }
    else {
        Write-Host "`nWrong IP-address!!  Press ENTER to try again or Ctrl+C to exit" -ForegroundColor Red
    }
}

Write-Host "`nServer with serial number $servername was found by IP address $ip" -ForegroundColor Green
$servername = ("ILO-$servername")

Disable-HPiLOCertificateAuthentication
Set-HPiLOSessionTimeOut -TimeOut 120

[string]$defaultpass = Read-Host "`nEnter default password for ILO Administrator account from sticker"
$check = (Get-HPiLONICInfo -Server $ip -Username Administrator -Password $defaultpass)
while (($check).status_type -ne "OK") {
    Write-Host "`n<<  Attention, wrong default password!  >>`nPress ENTER to try again or CTRL-C to exit" -ForegroundColor Red
    Read-Host
    [string]$defaultpass = Read-Host "`nEnter default password for ILO Administrator account from sticker"
    $check = (Get-HPiLONICInfo -Server $ip -Username Administrator -Password $defaultpass)
}
Write-Host "Password is"($check).status_type -ForegroundColor Green

function Test-Administrator {  
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}

$IfAdmin = Test-Administrator

if ($IfAdmin -eq $false) {
    Write-Host
    Write-Host "< You can't add records to DNS and reservations to DHCP >" -ForegroundColor Red
    Write-Host "<        You will not issue certificate from CA         >" -ForegroundColor Red
    Write-Host "<    Press ENTER to continue or CTRL-C to end script,   >" -ForegroundColor Red
    Write-Host "<   then restart Powershell console 'As Administrator'  >" -ForegroundColor Red
    Read-Host 
}

if ((find-hpilo $ip -WarningAction 0).pn -match ".*(ILO 4)") {
    [string]$mac =(($check.nic.mac_address)[0]).Replace(":", "-")
}
if ((find-hpilo $ip -WarningAction 0).pn -match ".*(ILO 5)") {
    [string]$mac = ($check).ilo.mac_address.Replace(":", "-")
}

if (($ip -like "10.200.204*") -or ($ip -like "10.200.205*") -or ($ip -like "10.200.206*") -or ($ip -like "10.200.207*")) {
    $DHCPScopeID = "10.200.204.0"
    $DHCPServer = "core-dhcp-5.orglot.office"
}
if ($ip -like "10.200.201*") {
    $DHCPScopeID = "10.200.201.0"
    $DHCPServer = "core-dhcp-5.orglot.office"
}
if ($ip -like "192.168.33*") {
    $DHCPScopeID = "192.168.33.0"
    $DHCPServer = "dhcp-1.orglot.office"
}
if ($ip -like "10.50.4*") {
    $DHCPScopeID = "10.50.4.0"
    $DHCPServer = "core-dhcp-3.orglot.office"
}

Write-Host "Searching MAC-address $mac"
$lease = (Get-DhcpServerv4Lease -ComputerName $DHCPServer -ScopeId $DHCPScopeID | Where-Object {$_.clientid -like "$mac*"})

if ($($lease | Measure-Object).Count -eq 0) {
    Write-Host "No DHCP lease was found! Press ENTER to continue without reservation or CTRL-C to exit" -ForegroundColor Red
    Read-Host
}

if ($($lease | Measure-Object).Count -eq 1) {
    $lease | Add-DhcpServerv4Reservation -ComputerName $DHCPServer -Verbose
    Start-Sleep -Seconds 5
    if ($? -eq $false) {
        Write-Host "Something wrong with DHCP lease, please investigate info above" -ForegroundColor Red
        Write-Host "Press ENTER to continue without reservation or CTRL-C to exit" -ForegroundColor Red
       Read-Host
    }
    Write-Host "DHCP scope to be replicated:"
    Invoke-DhcpServerv4FailoverReplication -ComputerName $DHCPServer -ScopeId $DHCPScopeID -Force
    Write-Host
}

else {
    $lease
    Write-Host "`n`nSomething wrong with DHCP lease, please investigate info above" -ForegroundColor Red
    Write-Host "Press ENTER to continue without reservation or CTRL-C to exit" -ForegroundColor Red
    Read-Host
}

$Error.Clear()

Write-Host "Adding A-record to DNS..."
Add-DnsServerResourceRecordA -ZoneName $forest -ComputerName dc-1.orglot.office -Name $servername -IPv4Address $ip

Read-Host -Prompt "Are you sure to shutdown server $servername`? Press ENTER to shutdown or CTRL-C to end script"
Set-HPiLOHostPower -Server $ip -user Administrator -Password $defaultpass -HostPower Off

Write-Host "Enabling LDAP"
Set-HPiLODirectory -Server $ip -Username Administrator -Password $defaultpass -LDAPDirectoryAuthentication Use_Directory_Default_Schema -LocalUserAccount Yes -ServerAddress $forest `
    -ServerPort "636" -UserContext1 "OU=Admins,DC=orglot,DC=office" -UserContext2 "@orglot.office" -ErrorAction Stop

Write-Host "Adding security groups"
Set-HPiLOSchemalessDirectory -Server $ip -GroupAccount "Yes" -Username Administrator -Password $defaultpass `
    -group1name $dn1 -Group1sid $sid1 -Group1Priv $iloadmin `
    -group2name $dn2 -Group2sid $sid2 -Group2Priv $ilooperator `
    #-group3name $dn3 -Group3sid $sid3 -Group3Priv $iloadmin
Start-Sleep -Seconds 30 -Verbose

Write-Host "Installing ILO Advanced license key"
$check = Get-HPiLOLicense -Server $ip -Username Administrator -Password $defaultpass
if (($check.LICENSE_TYPE -eq "iLO Advanced") -and ($check.LICENSE_STATE -eq "confirmed")) {
    Write-Host "ILO Advanced license key is already installed"
}
else {
    $check
    Read-Host "Investigate information above and press ENTER to install iLO Advanced license"
    Set-HPiLOLicenseKey -Server $ip -Username Administrator -Password $defaultpass -Key $ilolic
}

Write-Host "Please enter Domain Lead Admin credentials when prompted"
$cr = get-credential -Message "Please enter Domain Lead Admin credentials"
$check = Get-HPiLODirectory -Server $ip -Credential $cr
while (($check).STATUS_MESSAGE -ne "OK") {
    $check.status_message
    Write-Host "`n<<  Attention, wrong domain password!  >>`n`Press ENTER to try again or CTRL-C to exit" -ForegroundColor Re
    $cr = Get-Credential 
    $check = Get-HPiLODirectory -Server $ip -Credential $cr
}

Write-Host "Domain connectivity is"($check).status_message -ForegroundColor Green
Start-Sleep -Seconds 5 -Verbose

Write-Host "`n`nSetting FQDN"
Set-HPiLOServerFQDN -Server $ip -Credential $cr -ServerFQDN "$servername.$forest"
Start-Sleep -Seconds 5 -Verbose

Write-Host "`n`nSetting server name"
Set-HPiLOServerName -Server $ip -Credential $cr -ServerName $servername
Start-Sleep -Seconds 5 -Verbose

Write-Host "`n`nSetting ILO FQDN"
Set-HPiLOSMHFQDN -Server $ip -Credential $cr -SMHFQDN $servername
Start-Sleep -Seconds 5 -Verbose

Write-Host "`n`nSetting network name"
Set-HPiLONetworkSetting -Server $ip -Credential $cr -DNSName $servername
Start-Sleep -Seconds 30 -Verbose

Write-Host "`n`nSetting SNMP"
Set-HPiLOSNMPIMSetting -Server $ip -Credential $cr -SNMPAddress1ROCommunity "public" -SNMPAddress1 "10.200.7.70"
Start-Sleep -Seconds 5 -Verbose

Write-Host "`n`nSetting mail alerts"
Set-HPiLOGlobalSetting -Credential $cr -Server $ip -AlertMail Yes -AlertMailEmail 'ilo@stoloto.ru' -AlertMailSenderDomain 'stoloto.ru' `
    -AlertMailSMTPPort "25" -AlertMailSMTPServer 'mail.stoloto.ru'-DisableCertificateAuthentication
Start-Sleep -Seconds 5 -Verbose

Write-Host "`n`nRenaming default user to iload"
Set-HPiLOUser -Server $ip -UserLoginToEdit Administrator -NewUserLogin iload -Credential $cr
Start-Sleep -Seconds 5 -Verbose

Write-Host "`n`nGenerating and setting password for user iload"
[Reflection.Assembly]::LoadWithPartialName("System.Web")
$newpass = [System.Web.Security.Membership]::GeneratePassword(16, 0)
Set-HPiLOPassword -Server $ip -Credential $cr -UserLoginToEdit iload -NewPassword $newpass

Write-Host "`n`nSending mail to $mail with new password"
Send-MailMessage -To $mail -From "<ilo@stoloto.ru>" -Subject "$servername $newpass" -SmtpServer mail.stoloto.ru -Body "`n`nhttps://$servername.$forest`n`n$servername`n`n$newpass`n`n"
Start-Sleep -Seconds 5 -Verbose

Write-Host "`n`nGenerating certificate request..."
$req = (Get-HPiLOCertificateSigningRequest -Server $servername -Credential $cr  -Country "RU" -State "Moscow Region" -Locality "Moscow" -Organization "Stoloto JSC" -OrganizationalUnit "ITD" -CommonName "$servername.$forest")
Start-Sleep -Seconds 30 -Verbose
While (($req).CERTIFICATE_SIGNING_REQUEST -notlike "-----BEGIN*") {
    Start-Sleep -Seconds 20 -Verbose
    $req = (Get-HPiLOCertificateSigningRequest -Server $servername -Credential $cr  -Country "RU" -State "Moscow Region" -Locality "Moscow" -Organization "Stoloto JSC" -OrganizationalUnit "ITD" -CommonName "$servername.$forest")
    Write-Host "Please wait..."
}
$(($req).CERTIFICATE_SIGNING_REQUEST) | Out-File $folderpath\$servername.req
$reqpath = ("$folderpath\$servername.req").replace('\\', '\')
$cerpath = ("$folderpath\$servername.cer").replace('\\', '\')
certreq -config "v-pica.orglot.office\Gosloto Class 1 Issuing SubCA"  -attrib "CertificateTemplate:Core. iLO\nSAN:dns=$servername&dns=$servername.$forest&ipaddress=$ip" -submit $reqpath $cerpath

$cer = get-content -Path  $cerpath -Raw
Write-Host "`n`nImporting certificate $cer..."
Import-HPiLOCertificate -Server $servername -Credential $cr -Certificate $cer -Verbose

Write-Host "`n`nILO is being reset... Wait for few minutes then go https://$servername.$forest or https://$ip to check and upgrade firmware"
