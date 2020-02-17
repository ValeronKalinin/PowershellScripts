$cred=Get-Credential
Connect-VIServer  -Server "sap-vc" -Credential $cred

$tags = Import-Csv -Path C:\Users\v.kalinin\Desktop\1.csv -Encoding UTF8

 $existingt=Get-Tag 
 $categorys = "Product", "Environment", "Service","Department", "The responsible person", "Expiration Date"

    foreach ($category in $categorys){
            $existingt=Get-Tag 
            if ($existingt.Category -notcontains $category)
            {
                New-TagCategory  -Name $category
            }
    
    }

foreach ($tag in $tags)
{
    $existingt=Get-Tag 
     
         foreach ($category in $categorys){
          
                if ($existingt.Name -notcontains $tag.$category)
                {
            
                $tt=$tag.$category -split ","
                foreach ($t in $tt){New-Tag -Name $t.trim()   -Category $category -Description $category}
            
                }
            }
    get-vm $tag.'VM Name'
}