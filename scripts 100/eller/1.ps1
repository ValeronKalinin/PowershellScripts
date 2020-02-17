$summ=0
$i=0
while ($i -lt 1000)
{
if (($i%3) -eq 0 -or ($i%5) -eq 0){
$summ+=$i
}
$i++
}

$summ


