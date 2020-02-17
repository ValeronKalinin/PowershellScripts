[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#Файл формируется с помощью find-hpilo -full
$dstart=get-date
$allilo = Import-Csv -Path C:\Users\v.kalinin\Desktop\hpilo.csv # -Delimiter ";"

$table = $null; $table = @()
$full = $null
$fullp = $null
$jobres = $null; $jobres = @()

<#function getWarranty  {
 
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
    }    #> 

foreach  ($ilo in $allilo) {
# Get-Job| where {$_.State -like "Running"} -LT 10
    
    
    $Waranty = $null
    Get-Job| where {$_.State -like "Completed" -and  $_.HasMoreData -like "True"}| % {$table+= ($_ |Receive-Job)}
    Get-Job| where {$_.State -like "Completed" -and  $_.HasMoreData -like "False"}|Remove-Job
    (Get-Job).ChildJobs.Count
    $table.Count
    if ((Get-Job).ChildJobs.Count -gt 16){
    Start-Sleep 5
    
    }

    #Start-Sleep 5
    start-job -ScriptBlock {
    param ($ilo)
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

    function getWarranty  {
 
 param ([string]$serial,[string]$productNumber1)
 $Waranty=$null
 $full = $null
 $fullp = $null
    
    while ($Waranty.Length -le  3 -or $Waranty.Length -gt 50)
    {
    $full = Invoke-WebRequest -Method Post -Uri "https://support.hpe.com/hpsc/wc/public/find?submitButton=Senden&rows[0].item.countryCode=US&rows[0].item.serialNumber=$serial&rows[0].item.productNumber=$productNumber"
    #$fullp = (($full.ParsedHtml.body.outerText -split "`n", "") | ? {$_}) -replace '(?m)^\s*?\n', " "
        
    $fullp = (($full.ParsedHtml.body.outerText -split "`n", "") | ? {$_}) -replace '(?m)^\s*?\n', " " -match "HP*" -inotmatch "var*"
    $fullp -replace '(^\s+|\s+$)', ' ' -replace '\s+', '' | select -Unique  | Out-Null

    $Waranty =  ($fullp| Select-String "Support" | where {-not ($_ -match "Expired" -or $_ -match "Packaged support has a packaged support ID." -or $_ -match "Central" )}) -replace "Support agreement#####",""  -replace "Packaged support#####",""
  
    if(($Waranty | select -First 1) -notlike "Base Warranty" -or ($Waranty|select -first 2| select -last 1) -notlike "Base Warranty" ){
    
    $Waranty=$Waranty| select -First 1
    
    }

    else {$Waranty = $fullp}
    
    }
    return $Waranty
    }  

$jobres = $null; $jobres = @()

  $Waranty = getWarranty -serial $ilo.HSI_SBSN -productNumber1 $ilo.HSI_PRODUCTID
  
   
    $params = @{

        hostname     = $ilo.HOSTNAME                    
        IP           = $ilo.IP
        SPN          = $ilo.HSI_SPN
        PN           = $ilo.HSI_PRODUCTID
        SerialNumber = $ilo.HSI_SBSN
        UUID         = $ilo.HSI_UUID
        Warranty     = $Waranty
    }
    #$table += New-Object -TypeName psobject -Property $params
    $jobres+= New-Object -TypeName psobject -Property $params
    $jobres | out-file -FilePath C:\Users\v.kalinin\Desktop\warranty1.txt -Append
    $jobres | export-csv -Path C:\Users\v.kalinin\Desktop\warranty1.csv -Append -NoTypeInformation
    return  $jobres
    } -ArgumentList ($ilo)
   
}

    Get-Job| where {$_.State -like "Completed" -and  $_.HasMoreData -like "True"}| % {$table+= ($_ |Receive-Job)}
    Get-Job| where {$_.State -like "Completed" -and  $_.HasMoreData -like "False"}|Remove-Job
    
    $dstop=get-date
    $dres= $dstop-$dstart
    $dres.TotalSeconds
#($fullp| Select-String "Support" | where {-not ($_ -match "Expired" -or $_ -match "Packaged support has a packaged support ID." -or $_ -match "Central" )}) -replace "Support agreement#####","" 