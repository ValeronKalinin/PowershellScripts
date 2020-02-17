[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

function getWarranty  {
 
 param ([string]$serial,[string]$productNumber1)

 $full = $null
 $fullp = $null

    $full = Invoke-WebRequest -Method Post -Uri "https://support.hpe.com/hpsc/wc/public/find?submitButton=Senden&rows[0].item.countryCode=US&rows[0].item.serialNumber=$serial&rows[0].item.productNumber=$productNumber"
    #$fullp = (($full.ParsedHtml.body.outerText -split "`n", "") | ? {$_}) -replace '(?m)^\s*?\n', " "
        
    $fullp = (($full.ParsedHtml.body.outerText -split "`n", "") | ? {$_}) -replace '(?m)^\s*?\n', " " -match "HP*" -inotmatch "var*"
    $fullp -replace '(^\s+|\s+$)', ' ' -replace '\s+', '' | select -Unique  | Out-Null

    $Waranty =  ($fullp| Select-String "Support" | where {-not ($_ -match "Expired" -or $_ -match "Packaged support has a packaged support ID." -or $_ -match "Central" )}) -replace "Support agreement#####","" 
  
    if(($Waranty | select -First 1) -notlike "Base Warranty" -or ($Waranty|select -first 2| select -last 1) -notlike "Base Warranty" ){
    
    $Waranty=$Waranty| select -First 1
    
    }

    else {$Waranty =$Waranty}
 
    return $Waranty
    }     

   getWarranty -serial "CZJ82701K5" -productNumber1 "867960-B21"