

$res=@()
$bad=@()

$vms=import-csv -Path C:\Users\v.kalinin\Desktop\vmname.csv -Encoding Default

foreach ($vm in $vms){
    if (get-vm  -Name $vm.vmname) {
    
    $vmres=New-Object psobject
    $vmprop= get-vm  -Name $vm.vmname.Trim()| select *

    $vmres| Add-Member -MemberType NoteProperty -Name "VMname" -Value $vmprop.Name
    $vmres| Add-Member -MemberType NoteProperty -Name "NumCpu" -Value $vmprop.NumCpu
    $vmres| Add-Member -MemberType NoteProperty -Name "MemoryGB" -Value $vmprop.MemoryGB
    $b=1
    while ($b -le 11){
    $vmres| Add-Member -MemberType NoteProperty -Name "drive$b" -Value ""
    $b++}

    $drives=get-vm  -Name $vm.vmname| Get-HardDisk
    
            $i=1
            foreach ($drive in $drives){

            $vmres| Add-Member -MemberType NoteProperty -Name "drive$i" -Value ([math]::round($drive.CapacityGB ,0)) -Force
            $i++

            }
$vmres
$res+=$vmres}

else{
$bad+=$vm.vmname

}

}

$res | select VMname,NumCpu,MemoryGB,drive1   ,	drive2   ,	drive3   ,	drive4   ,	drive5   ,	drive6   ,	drive7   ,	drive8   ,	drive9   ,	drive10  ,	drive11  | Export-Csv -Path C:\Users\v.kalinin\Desktop\vmnameex.csv -NoTypeInformation -Encoding UTF8
$res.count