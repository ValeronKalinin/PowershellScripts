$data=Read-Host 
$i=0;$check=0

while(($i -lt $data.Length) -and ($check -ge 0))
{
if ( $data[$i] -eq "("){$check++}
else {$check-- }
$i++
}

if ($check -eq 0){Write-Host "$data is ok" }
else {Write-Host "$data is not ok in element: " $i  }