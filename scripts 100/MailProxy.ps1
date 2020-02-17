$simusers=get-aduser -SearchBase "OU=SIM,OU=RealUsers,OU=Users,OU=.CompanyRoot,DC=orglot,DC=office" -Filter * -Properties  proxyaddresses, mail| select name,mail, proxyAddresses
$list=$null; $list=@()

foreach ($simuser in $simusers)

{
$name=$simuser.name
$mail=$simuser.mail
$proxys=$simuser.proxyAddresses -replace "smtp:", ""

foreach ($proxy in $proxys)
{
    if ($proxy -like "*sim-sim.com" -and $proxy -notlike $mail)
    {


     
               $props =@{
                    name=$name 
                    mail1=$mail
                    mail2= $proxy
                 
                    }
                $obj1=New-Object -TypeName psobject -Property $props
               $list+=$obj1

    
   
    
    }
}

#$proxys

}
$list| select name,mail2,mail1| sort name | export-csv -Path C:\Users\v.kalinin\Desktop\sim.csv -Encoding UTF8 -NoTypeInformation