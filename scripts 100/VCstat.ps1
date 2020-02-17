#Name                 ConnectionState PowerState NumCpu CpuUsageMhz CpuTotalMhz   MemoryUsageGB   MemoryTotalGB Version


$cred=Get-Credential
Connect-VIServer  -Server 8bus-vc.orglot.office -Credential $cred

$VCstat=New-Object -TypeName psobject

$hosts=Get-VMHost


$NumCpu         =   ($hosts.numcpu          | measure -Sum).Sum
$CpuTotalMhz    =   ($hosts.CpuTotalMhz     | measure -Sum).Sum
$CpuUsageMhz    =   ($hosts.CpuUsageMhz     | measure -Sum).Sum
$MemoryUsageGB  =   ($hosts.MemoryUsageGB   | measure -Sum).Sum
$MemoryTotalGB  =   ($hosts.MemoryTotalGB   | measure -Sum).Sum



$VCstat| Add-Member -MemberType NoteProperty -Name "NumCpu"         -Value $NumCpu          -Force
$VCstat| Add-Member -MemberType NoteProperty -Name "CpuTotalMhz"    -Value $CpuTotalMhz     -Force
$VCstat| Add-Member -MemberType NoteProperty -Name "CpuUsageMhz"    -Value $CpuUsageMhz     -Force
$VCstat| Add-Member -MemberType NoteProperty -Name "MemoryUsageGB"  -Value $MemoryUsageGB   -Force
$VCstat| Add-Member -MemberType NoteProperty -Name "MemoryTotalGB"  -Value $MemoryTotalGB   -Force
$VCstat| Add-Member -MemberType NoteProperty -Name "Hosts"          -Value $hosts.Count     -Force