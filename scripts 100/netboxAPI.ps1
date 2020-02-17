#$cred=Get-Credential
#Костыли для того что бы работало с хуевым сертификатом

add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Ssl3, [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12
############################################################################


#Ссылка на девайсы из нетбокса, лимит на страницу 10к, что бы не мудохаться
$api_base_url = "https://dcim1.net.stoloto.ru/api/dcim/devices/?limit=10000"

$headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
$headers.Add("Accept-Charset" , 'utf-8')
$headers.Add("Authorization", 'Token 43cac414a9a50472367ea8c18c13cd7f8f730d2f')
$headers.Add("Content-Type", "application/json; charset=utf-8")
$headers.Add("Accept", "application/json; charset=utf-8")

#Запрос в коробку. Ответ загоняем в переменную
$devices=Invoke-RestMethod -Uri $api_base_url -Headers $headers

#готовим переменную под результаты.                                                 
$locationtable=$null; $locationtable=@()                                            
                                                                                    
# Загоняем в переменную данные об ILO из определенной подсети                       
$array=Find-HPiLO 10.200.201,10.200.204, 10.200.205, 10.200.206,10.200.207,10.200.224.0,10.200.225.0,10.200.226.0,10.200.227.0
#$low=$null                                                                         
#$upp=$null                                                                         
                                                                                    
                                                                                    
#Колбасим каждый элемент полученного массива                                        
foreach ($arr in $array)                                                            
                                                                                    
{                                                                                   
                                                                                    
#$low=$arr.SerialNumber.ToLower()                                                   
$SN=$arr.SerialNumber.ToString()                                                    
                                                                                    
$low=$low.Trim()                                                                    
$upp=$upp.Trim()                                                                    
                                                                                    
$rackunit=$devices.results| where {$_.serial -match $SN   <#-or $_.serial -Contains $upp #>}
#$rackunit                                                                          
                                                                                    
    $props =@{                                                                      
            Hostname=$arr.hostname                                                  
            IP=$arr.ip                                                              
            Device=$arr.SPN
            ILO=$arr.PN
            serial=$arr.SerialNumber
            rack=($rackunit.rack.name).remove(8).trim()
            unit=$rackunit.position
            bay=$rackunit.parent_device.device_bay.name
            location= ($rackunit.rack.name).remove(8).trim()+" "+$rackunit.position+$rackunit.parent_device.device_bay.name
            }
 $obj=New-Object -TypeName psobject -Property $props
 $locationtable+=$obj

}
$locationtable
$locationtable.count

$unic=($locationtable| sort serial -Unique  )
#$460=($locationtable| sort serial -Unique | where Device -like "*460*" )
$unic.Count
<#
foreach ($un in $unic)
{
set-HPiLOSNMPIMSetting -SNMPSysLocation $un.location -Server $un.IP -Credential $cred
}
#>
#

#set-HPiLOSNMPIMSetting -SNMPSysLocation $location -Server $i.IP -Credential $cred
#Set-HPiLOSNMPIMSetting -Server $ip -Credential $cr -SNMPAddress1ROCommunity "public" -SNMPAddress1 "10.200.7.70"