$dstart = Get-Date
$allilo = Import-Csv -Path "E:\git\Powershell\csv\hpilo.csv"
($allilo | Select-Object -Unique -Property HSI_SBSN).count

$result = @{}
$i = 0
$invoke = @()
$invoke = "https://support.hpe.com/hpsc/wc/public/find?submitButton=Senden"
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Invoke-WebRequest -Uri "https://support.hpe.com/" -SessionVariable session -UserAgent ([Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer)
#$session.Cookies.GetCookies("https://support.hpe.com/hpsc/wc/public/find?submitButton=Senden")
#Invoke-WebRequest -Uri $invoke -WebSession $session -UserAgent ([Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer)
function invoke {
    param ($invoke)
            
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
    Start-Job -ScriptBlock {

        param ($invoke)
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        #$full = Invoke-WebRequest -Method Post -Uri "$invoke" 
        #$invoke
        #$fullp = (($full.ParsedHtml.body.outerText -split "`n", "") | Where-Object { $_ }) -replace '(?m)^\s*?\n', " " -match "HP*" -inotmatch "var*"
        $fullp = (((Invoke-WebRequest -Method Post -Uri "$invoke" -UseBasicParsing  -UserAgent ([Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer)).ParsedHtml.body.outerText -split "`n", "") | Where-Object { $_ }) -replace '(?m)^\s*?\n', " " -match "HP*" -inotmatch "var*"
        $check = $fullp -match "where they appear, conceal Contract and Warranty numbers and other sensitive information"
        $fullp.IndexOf("$check")
        $fullp = $fullp[$fullp.IndexOf("$check").$fullp.Length]
   
        $table = $null
        $table = @()

        foreach ($azaza in ($fullp -match "SN:  C")) {
            $param = @{
                strnum       = $fullp.IndexOf($azaza)
                serialNumber = ($fullp[$fullp.IndexOf($azaza)].Split(" ")[-1]).trim()               
                war          = $null

            }
            $table += New-Object -TypeName psobject -Property $param
        }
        #$table| select -Unique -Property serialNumber

        $tl = $table.Count
        $i = 0

        while ($i -lt $tl) {
            $counter = $null

            $startl = $table[$i].strnum
            $endl = ($table[$i + 1].strnum - 1 )

            if ($endl -eq -1) {

                $endl = $fullp.Count
            }
               
            $counter = $startl
                            
            $war = @()

            while ($counter -lt $endl) {
                if (($fullp[$counter]).Length -gt 1) {
                    $war += $fullp[$counter]                            
                }
                          
                $table[$i].war += $war
                $war = $null
                $counter++
            }
            $i++   
        }

        foreach ($t in $table) {
            $Waranty = ($t.war | Select-String "Support" | Where-Object { -not ($_ -match "Expired" -or $_ -match "Packaged support has a packaged support ID." -or $_ -match "Central" ) }) -replace "Support agreement#####", "" -replace "Packaged support#####", ""
  
            if (($Waranty | Select-Object -First 1) -notlike "Base Warranty" -or ($Waranty | Select-Object -first 2 | Select-Object -last 1) -notlike "Base Warranty" ) {
    
                $Waranty = $Waranty | Select-Object -First 1
    
            }

            else { $Waranty = $t.war }

            $t.war = $Waranty

        }

        return $table
        
    } -ArgumentList($invoke)
}

foreach ($ilo in $allilo) {

    if ($i -lt 30) {           
        $invoke += "&rows[$i].item.countryCode=RU&rows[$i].item.serialNumber=" + $ilo.HSI_SBSN.Trim() + '&' + "rows[$i].item.productNumber=" + $ilo.HSI_PRODUCTID.Trim()            
    }
    else {       
        #$invoke
        invoke -invoke $invoke -session $session  
        $i = 0 
        $invoke = "https://support.hpe.com/hpsc/wc/public/find?submitButton=Senden"
        $invoke += "&rows[$i].item.countryCode=RU&rows[$i].item.serialNumber=" + $ilo.HSI_SBSN.Trim() + '&' + "rows[$i].item.productNumber=" + $ilo.HSI_PRODUCTID.Trim()       
    }
    $i++   
}

invoke -invoke $invoke -session $session

$result = Get-Job | Wait-Job | Receive-Job
$result.Count
($result | Select-Object serialNumber, war | Sort-Object serialNumber -Descending).Count
$result | Select-Object serialNumber, war | Sort-Object serialNumber -Descending | Out-GridView
$result | Select-Object serialNumber, war | Sort-Object serialNumber -Descending | Export-Csv -Path C:\Users\v.kalinin\Desktop\warranty1.csv -Encoding UTF8 -NoTypeInformation -Delimiter ";"
Get-Job | Remove-Job -Force

$dstop = Get-Date
$dres = $dstop - $dstart
$dres.TotalSeconds

$compare = Compare-Object -ReferenceObject ($allilo.HSI_SBSN | Sort-Object ).trim() -DifferenceObject ($result.serialNumber | Sort-Object).trim() -PassThru
$compare.Count
$compare

$HH = @()
foreach ($r in $result) {
    $p = @{
        SN       = $r.serialNumber
        IP       = ($allilo | where  HSI_SBSN -Like   $r.serialNumber.trim()).ip
        warranty = $r.war  
    }
    $HH += New-Object -TypeName psobject -Property $p

}

$HH | select SN, ip, warranty
<#
             foreach ($h in $hh)
             { 

                if ($h.ip -ne $null){
                        $h | out-file -FilePath 'C:\users\v.kalinin\Desktop\log.txt' -Append
                            (HPiLOSNMPIMSetting  -Server $h.ip -Username HW -Password pqhV=88!0qnm1pkk -DisableCertificateAuthentication ).SNMP_SYSTEM_ROLE_DETAIL| out-file -FilePath 'C:\users\v.kalinin\Desktop\log.txt' -Append
                                Set-HPiLOSNMPIMSetting -SNMPSystemRoleDetail $h.warranty -Server $h.ip -Username HW -Password pqhV=88!0qnm1pkk -DisableCertificateAuthentication| out-file -FilePath 'C:\users\v.kalinin\Desktop\log.txt' -Append
                }
             }
             
             
#>