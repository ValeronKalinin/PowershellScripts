$cred=Get-Credential
Connect-VIServer  -Server core-vc-ltt-01.orglot.office -Credential $cred

$tags = Import-Csv -Path C:\Users\v.kalinin\Desktop\ltt.csv -Encoding Default -Delimiter ";"

 $existingc=Get-TagCategory
 $categorys = "Product", "Environment", "Service","Department", "The Responsible Person" #, "Expiration Date"

    foreach ($category in $categorys){
            $existingc=Get-TagCategory 
            if ($existingc.Name -notcontains $category)
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
                New-Tag -Name $tag."$category" -Category "$category" -Description $category -ErrorAction SilentlyContinue
                }
                $vmtag=$null
                $vmtag= get-tag | where {$_.Name -like $tag.$category -and $_.Category -like $category} 
                $vmtag
               
                get-vm $tag.'VM Name' -ErrorAction SilentlyContinue| New-TagAssignment -Tag $vmtag -ErrorAction SilentlyContinue
                
    }
            

}
