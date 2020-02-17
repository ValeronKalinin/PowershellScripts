[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$allilo = Import-Csv -Path C:\Users\v.kalinin\Desktop\hpilo.csv
$invoke=$null
$c=0
$arr=@()

while ($c+20 -lt $allilo.Count)
{
    
    $c+=20
    $c
    $serversper20=$allilo|select -first $c| select -last 20
    $invoke="https://support.hpe.com/hpsc/wc/public/find?submitButton=Senden&"
    $i=0
    foreach ($s20 in $serversper20)
    {
    $invoke+="rows[$i].item.countryCode=US&rows[$i].item.serialNumber="+$s20.HSI_SBSN+'&'+"rows[$i].item.productNumber="+$s20.HSI_PRODUCTID
    $i++
    }
    
    $full=Invoke-WebRequest -Method Post -Uri "$invoke"

$fullp = (($full.ParsedHtml.body.outerText -split "`n", "") | ? {$_}) -replace '(?m)^\s*?\n', " " -match "HP*" -inotmatch "var*"
$check=$fullp -match "where they appear, conceal Contract and Warranty numbers and other sensitive information"
$fullp.IndexOf("$check")
$fullp=$fullp[$fullp.IndexOf("$check")..$fullp.Length]

$strNum=$null
$table=$null
$table=@()


foreach ($azaza in ($fullp -match "SN:  C"))
{
$param = @{
strnum = $fullp.IndexOf($azaza)
serialNumber     = $fullp[$fullp.IndexOf($azaza)].Split(" ")[-1]
war           =  $null

}
$table+= New-Object -TypeName psobject -Property $param
}
#$table| select -Unique -Property serialNumber

$tl=$table.Count
$i=0

            while ($i -lt $tl)
            {
            $counter=$null

            $startl = $table[$i].strnum
            $endl   = ($table[$i+1].strnum -1 )

                if ($endl -eq -1)
                {

                $endl=$fullp.Count
                }

                $table[$i].serialNumber

                $counter=$startl

                            
                            $war=@()

                            while ($counter -lt $endl)
                            {
                            if (($fullp[$counter]).Length -gt 1)
                            {
                            $war+=$fullp[$counter]
                            
                            }
           
                
            $table[$i].war+=$war
            $war=$null
            $counter++
            }
    $i++   
}



foreach ($t in $table)
{
$Waranty =  ($t.war| Select-String "Support" | where {-not ($_ -match "Expired" -or $_ -match "Packaged support has a packaged support ID." -or $_ -match "Central" )}) -replace "Support agreement#####",""  -replace "Packaged support#####",""
  
    if(($Waranty | select -First 1) -notlike "Base Warranty" -or ($Waranty|select -first 2| select -last 1) -notlike "Base Warranty" ){
    
    $Waranty=$Waranty| select -First 1
    
    }

    else {$Waranty = $t.war}

    $t.war=$Waranty

}

$table|Out-GridView
 
}
$allilo.HSI_SBSN| select -last ($allilo.Count -$c)

<#
#$full=Invoke-WebRequest -Method Post -Uri  "https://support.hpe.com/hpsc/wc/public/find?submitButton=Senden&rows[0].item.countryCode=US&rows[0].item.serialNumber=CZJ82200BY&rows[1].item.countryCode=US&rows[1].item.serialNumber=CZ27440HJY`
#&rows[2].item.countryCode=US&rows[2].item.serialNumber=CZJ83111VD" 


$full=Invoke-WebRequest -Method Post -Uri "$invoke"



$fullp = (($full.ParsedHtml.body.outerText -split "`n", "") | ? {$_}) -replace '(?m)^\s*?\n', " " -match "HP*" -inotmatch "var*"
$check=$fullp -match "where they appear, conceal Contract and Warranty numbers and other sensitive information"
$fullp.IndexOf("$check")
$fullp=$fullp[$fullp.IndexOf("$check")..$fullp.Length]





$strNum=$null
$table=$null
$table=@()


foreach ($azaza in ($fullp -match "SN:  C"))
{
$param = @{
strnum = $fullp.IndexOf($azaza)
serialNumber     = $fullp[$fullp.IndexOf($azaza)].Split(" ")[-1]
war           =  $null

}
$table+= New-Object -TypeName psobject -Property $param
}
#$table| select -Unique -Property serialNumber

$tl=$table.Count
$i=0

            while ($i -lt $tl)
            {
            $counter=$null

            $startl = $table[$i].strnum
            $endl   = ($table[$i+1].strnum -1 )

                if ($endl -eq -1)
                {

                $endl=$fullp.Count
                }

                $table[$i].serialNumber

                $counter=$startl

                            
                            $war=@()

                            while ($counter -lt $endl)
                            {
                            if (($fullp[$counter]).Length -gt 1)
                            {
                            $war+=$fullp[$counter]
                            
                            }
           
                
            $table[$i].war+=$war
            $war=$null
            $counter++
            }
    $i++   
}



foreach ($t in $table)
{
$Waranty =  ($t.war| Select-String "Support" | where {-not ($_ -match "Expired" -or $_ -match "Packaged support has a packaged support ID." -or $_ -match "Central" )}) -replace "Support agreement#####",""  -replace "Packaged support#####",""
  
    if(($Waranty | select -First 1) -notlike "Base Warranty" -or ($Waranty|select -first 2| select -last 1) -notlike "Base Warranty" ){
    
    $Waranty=$Waranty| select -First 1
    
    }

    else {$Waranty = $t.war}

    $t.war=$Waranty

}

$table|Out-GridView
    
    #>