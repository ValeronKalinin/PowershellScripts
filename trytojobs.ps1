

#Get-ChildItem -Path C: -Recurse | measure -Property length -Sum).Sum / 1mb
##### 1 поток
function 1line (){

$watch = [System.Diagnostics.Stopwatch]::StartNew()
$watch.Start() #Запуск таймера
$res=[math]::round(((Get-ChildItem -Path C:\ -Recurse| measure -Property length -Sum).Sum / 1mb),2)
$watch.Stop() #Остановка таймера
Write-Host $watch.Elapsed #Время выполнения 1 поток
return $res, $watch.Elapsed
}


############################################################################################################
# Несколько через workflow

function workfl () {
$dirs = Get-ChildItem -Path C:\   -Directory
$dirs=$dirs.fullname
$i=@();$i=$null

workflow getdirectoryes {
param ([string[]]$dirs)

foreach -parallel($dir in $dirs )
{

#Get-ChildItem -Path $dir   -Directory
$dirsize=(Get-ChildItem -Path $dir -Recurse | measure -Property length -Sum).Sum / 1mb

$poperties=@{directory=$dir
            size=$dirsize}
   $info=New-Object –TypeName PSObject –Prop $poperties
   $i+=$info
   $i
}
 
} 
$watch = [System.Diagnostics.Stopwatch]::StartNew()
$watch.Start() #Запуск таймера
$result= (getdirectoryes $dirs )
$watch.Stop() #Остановка таймера
Write-Host ""
Write-Host $watch.Elapsed #Время выполнения workflow


$res=($result |measure -Property size -Sum).Sum 
return $res, $watch.Elapsed
}




###################################################################################################
#Несколько через jobs

function jobsnotSteve() {
$watch = [System.Diagnostics.Stopwatch]::StartNew()
$watch.Start() #Запуск таймера

$dirsize=$null
$dirs = Get-ChildItem -Path C:\ -Directory 
$dirs=$dirs.fullname
$i=@();$i=$null

foreach  ($dir in $dirs )
{
 Start-Job -ScriptBlock { 
    param ($dir)

    
    $dirsize=(Get-ChildItem -Path $dir -Recurse | measure -Property length -Sum).Sum / 1mb
    $poperties=@{   directory=$dir
                    size=$dirsize}
    $info=New-Object –TypeName PSObject –Prop $poperties
    $i+=$info
    return $i} -ArgumentList $dir
 
}
$jobstat=(get-job|Wait-Job|Receive-Job)
$res = ($jobstat|measure -Property size -Sum).Sum 
$watch.Stop() #Остановка таймера
Write-Host ""
Write-Host $watch.Elapsed #Время выполнения JOBS
get-job | Remove-Job

 return $res, $watch.Elapsed 
 }

 #################################

1line 
jobsnotSteve
workfl
