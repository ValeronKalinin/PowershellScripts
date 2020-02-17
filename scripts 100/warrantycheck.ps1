



#Файл формируется с помощью find-hpilo -full
#$dstart=get-date
#$allilo = Import-Csv -Path C:\Users\v.kalinin\Desktop\hpilo.csv # -Delimiter ";"
$allilo=$compare
$table = $null; $table = @()
$full = $null
$fullp = $null

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
foreach ($ilo in $allilo) {
    $Waranty = $null
    $serial = $compare
    
    
            
    $full = Invoke-WebRequest -Method Post -Uri "https://support.hpe.com/hpsc/wc/public/find?submitButton=Senden&rows[0].item.countryCode=US&rows[0].item.serialNumber=$serial  -UseBasicParsing"
    $fullp = (($full.ParsedHtml.body.outerText -split "`n", "") <#| % {$_.trim()}#> | ? {$_}) -replace '(?m)^\s*?\n', " "
    
    
    
        $full = Invoke-WebRequest -Method Post -Uri  "https://support.hpe.com/hpsc/wc/public/find?submitButton=Senden&rows[0].item.countryCode=US&rows[0].item.serialNumber=$serial&rows[0].item.productNumber=$productNumber  -UseBasicParsing"
        $fullp = (($full.ParsedHtml.body.outerText -split "`n", "") | % {$_.trim()} | ? {$_}) -replace '(?m)^\s*?\n', " " -match "HP*" -inotmatch "var*"
        $fullp -replace '(^\s+|\s+$)', ' ' -replace '\s+', ' ' | select -Unique 
        Write-Host "Гарантия запрошена и записана в файл"
    }
    
    else {
        $fullp = (($full.ParsedHtml.body.outerText -split "`n", "") | ? {$_}) -replace '(?m)^\s*?\n', " " -match "HP*" -inotmatch "var*"
        $fullp -replace '(^\s+|\s+$)', ' ' -replace '\s+', '' | select -Unique 
        Write-Host "Гарантия запрошена и записана в файл"
    
    }

    $Waranty = ($fullp| Select-String "Support agreement#####" |select -First 1 ) -replace "Support agreement#####", ""
    if ($Waranty.Length -eq 0) {

        $Waranty = ($fullp| Select-String "Packaged support#####"|select -First 1 ) -replace "Packaged support#####", ""

    }

    if ($Waranty.Length -eq 0) {

        $Waranty = ($fullp| Select-String "Base Warranty"|select -First 1 ) -replace "Base Warranty$serial Wty:", ""

    }
    $Waranty                
           
    $params = @{

        hostname     = $ilo.HOSTNAME                    
        IP           = $ilo.IP
        SPN          = $ilo.HSI_SPN
        PN           = $ilo.HSI_PRODUCTID
        SerialNumber = $ilo.HSI_SBSN
        UUID         = $ilo.HSI_UUID
        Warranty     = $Waranty
    }
    
    $d=$null
    $d = New-Object -TypeName psobject -Property $params
    $table += $d
    $d| out-file -FilePath C:\Users\v.kalinin\Desktop\warranty.txt -Append
    



    #$dstop=get-date
    #$dres= $dstop-$dstart
    #$dres.TotalSeconds