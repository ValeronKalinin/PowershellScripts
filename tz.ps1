#Получаем данные
$data=Read-Host 

#Функция реализует алгоритм проверки на парность скобок и на то что открывающие идут перед закрывающими
function check ($data){
$open=0
$close=0
$i=0
$fdata=$data

if ( ($fdata[0] -like ")") -or ($fdata[-1] -like "(") ) 
{
 return Write-Host "WRONG start or end $data"
 break 
}


while ($i -lt $fdata.Length){
$test+=$fdata[$i]
$i++
}

foreach ($item in $test)
{
 if ($item -like "(") 
  {$open++ }
  if($item -like ")")
  {$close++}
}

if($open -ne $close){ 

return Write-Host "WRONG number of elements" 
break}
return 1
}
$i=0

#Ищем вхождения вида () и "закрываем" их имитируем решение того что в скобках. Выход из цикла когда встретим неправильное сочетание скобок
 while (($i -lt $data.Length) -and (check -data $data) -like "1") {
 
 if($data[$i] -like ")" -and $data[$i-1] -like "(")

 {
 
  $data=$data.Remove($i-1,$i)
  #$data
  $i=0
 }

 $i++
}
