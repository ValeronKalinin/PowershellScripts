$Ilo=Find-HPiLO 10.200.201,10.200.204,10.200.205,10.200.206, 10.200.224,10.200.225,10.200.226
$Servers=@()



foreach ($i in  $ilo){


        if((Get-HPiLOHostPower -Server $i -Username HW -Password "pqhV=88!0qnm1pkk" -DisableCertificateAuthentication).HOST_POWER -eq "OFF"){
        $Servers+=$i
        }
        
      

}


