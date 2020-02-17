
$date=Get-Date
$path     = Split-Path -parent $MyInvocation.MyCommand.Definition
$firedcsv = $path + "\fired.csv"
$names = Import-Csv $firedcsv
$log = $path + "\Совпадений_нет.txt"
$exSamAccountName=$path + "\Совпадения_по_SamAccountName.csv"
$exDisplayName=$path + "\Совпадения_по_имени.csv"

#$names 


foreach ($name in $names)

{

if ($name.Мail)


{

#$sn=$name.Мail.Split("@")[0]

try {
        Get-ADUser -Properties * -Identity ($name.Мail.Split("@")[0])|select  name,SamAccountName,@{n="Должность из AD";e={$_.title}},@{n="Должность из файла";e={$name.title}},@{n="Департамент из AD";e={$_.department}},@{n="Департамент из файла";e={$name.department}},Enabled | Export-Csv $exSamAccountName -Append -Encoding UTF8
    }

catch {
Write-Host "[ERROR]`t NOT EXIST!!!!! : $($_.Exception.Message)" 
$date.ToString() + "[ERROR]`t NOT EXIST!!!!! : $($_.Exception.Message)" | Out-File $log -Append}
}

if (!($name.Мail))
{
#$name=$name.name.Trim() 
#Get-ADUser -Filter *| where {$_.name -like $name.name.Trim()}
try {
        $n=$name.name.Trim()
        Get-ADUser -Properties * -filter {Name -like $n } |select name,SamAccountName,@{n="Должность из AD";e={$_.title}},@{n="Должность из файла";e={$name.title}},@{n="Департамент из AD";e={$_.department}},@{n="Департамент из файла";e={$name.department}},Enabled | Export-Csv $exDisplayName -Append -Encoding UTF8
    }

catch {
Write-Host "[ERROR]`t NOT EXIST!!!!! : $($_.Exception.Message)" 
$date.ToString() + "[ERROR]`t NOT EXIST!!!!! : $($_.Exception.Message)" | Out-File $log -Append}
}


}
 