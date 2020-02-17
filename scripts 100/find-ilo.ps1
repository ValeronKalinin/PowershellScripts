$ilos=Import-Csv -Path 'C:\Users\v.kalinin\Desktop\ilo2.csv'
$list=$null; $list=@{}

foreach ($ilo in $ilos)
{
$list+=find-hpilo $ilo.ilo.trim()


}
