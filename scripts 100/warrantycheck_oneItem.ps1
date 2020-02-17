

#CZJ82700P2	867959CZJ82700P2	867959-B21	ILO-CZJ82700P2.orglot.office	10.200.204.123	ProLiant DL360 Gen10	{}	101ea225-466d-4d76-8706-5541a43c97d0	



#Файл формируется с помощью find-hpilo -full




[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    $Waranty = $null
    $serial = 	"CZJ5460LT0"
    
    
            
   $full = Invoke-WebRequest -Method Post -Uri "https://support.hpe.com/hpsc/wc/public/find?submitButton=Senden&rows[0].item.countryCode=US&rows[0].item.serialNumber=$serial" -UserAgent ([Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer)
    $fullp = (($full.ParsedHtml.body.outerText -split "`n", "") | ? {$_}) -replace '(?m)^\s*?\n', " "
     
    if ($fullp -match "Please enter a product number below.") {
        
        #Write-Host "Для проверки гарантии данного сервера, требуется ввести ProductNumber. Пробуем найти его автоматически по SNMP"

        
            $productNumber="867959-B21"
     
       
        
        $full = Invoke-WebRequest -Method Post -Uri  "https://support.hpe.com/hpsc/wc/public/find?submitButton=Senden&rows[0].item.countryCode=US&rows[0].item.serialNumber=$serial&rows[0].item.productNumber=$productNumber"
        $fullp = (($full.ParsedHtml.body.outerText -split "`n", "") | % {$_.trim()} | ? {$_}) -replace '(?m)^\s*?\n', " " -match "HP*" -inotmatch "var*"
        $fullp -replace '(^\s+|\s+$)', ' ' -replace '\s+', ' ' | select -Unique | Out-Null
        #Write-Host "Гарантия запрошена и записана в файл"
    }
  
    else {
        $fullp = (($full.ParsedHtml.body.outerText -split "`n", "") | ? {$_}) -replace '(?m)^\s*?\n', " " -match "HP*" -inotmatch "var*"
        $fullp -replace '(^\s+|\s+$)', ' ' -replace '\s+', '' | select -Unique  | Out-Null
        #Write-Host "Гарантия запрошена и записана в файл"
    
    }

   
    $Waranty =  ($fullp| Select-String "Support" | where {-not ($_ -match "Expired" -or $_ -match "Packaged support has a packaged support ID." -or $_ -match "Central" )}) -replace "Support agreement#####",""  
    $Waranty          
    

