$hash=@{}
$massiv=@()
$hash.i ="i" 
$hash.b ="b"

$hash
$massiv+=$hash
$massiv

"get-childitem -Path "C:\Program Files\Microsoft SQL Server\Data\" | where name -like "*mdf"| select @{n='{#FILENAME}'; e={$_.name}}| ConvertTo-Json"