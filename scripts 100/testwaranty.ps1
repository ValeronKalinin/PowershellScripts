
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$full=Invoke-WebRequest -Method Post -Uri  "https://support.hpe.com/hpsc/wc/public/find?submitButton=Senden&rows[0].item.countryCode=US&rows[0].item.serialNumber=CZJ82200BY&rows[1].item.countryCode=US&rows[1].item.serialNumber=CZ27440HJY" 
$fullp = (($full.ParsedHtml.body.outerText -split "`n", "") | ? {$_}) -replace '(?m)^\s*?\n', " " -match "HP*" -inotmatch "var*"
$fullp

$strNum=$null
$table=@()

foreach ($azaza in ($fullp -match "###"))
{
$param = @{
strnum = $fullp.IndexOf($azaza)
serialNumber     = $fullp[$fullp.IndexOf($azaza)-1].Split(" ")[-1]

}
$table+= New-Object -TypeName psobject -Property $param
}
$table
#$sn=$fullp[$fullp.IndexOf($azaza)-1].Split(" ")[-1]