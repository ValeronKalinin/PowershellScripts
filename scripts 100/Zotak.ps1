$proxy0="62.76.133.60"
$proxy1="62.76.133.61"
$m9="217.77.107.100"
$ipinfo = Invoke-RestMethod http://ipinfo.io/json
$ip=$ipinfo.ip


if (!($ipinfo.ip -eq $proxy0 -or $ipinfo.ip  -eq $proxy1 -or $ipinfo -eq $m9 -or $ipinfo.ip -eq $null ))
{
echo   "External IP  is $ip. Proxy IP is $proxy0 $proxy1." |mailx -v -A stoloto -s "Proxy check FAILED!" Core.alarm@stoloto.ru
}
