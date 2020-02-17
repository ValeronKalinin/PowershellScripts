$i1=0
$i2=1
$new = $null
$summ=$null
while ($new -lt 4000000)
{
$new=$i1+$i2
$i1=$i2
$i2=$new
$new

if(($new%2) -eq 0){
$summ+=$new
}

}