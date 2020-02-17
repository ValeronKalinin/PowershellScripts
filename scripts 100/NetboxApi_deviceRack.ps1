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
 $rackunit=$devices.results
#($rackunit |where {$_.site.id -eq "2" -and $_.rack.id -like "48"}).device_type.url

$res=@()
#$rackunit.rack.display_name -like ""
foreach($dev in ($rackunit |where {$_.rack.id -like "68"}))
#foreach($dev in ($rackunit |where {$_.rack.display_name -like "*5/01/01*"}))
{
$uri= $dev.device_type.url
$pos=$dev.position


$res+=Invoke-RestMethod -Uri $uri  -Headers $headers| select display_name, model, @{n="position";e={$pos}}, u_height 
}

$res | sort position -Descending| Out-GridView