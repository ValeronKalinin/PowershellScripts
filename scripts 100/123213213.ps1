#Get-Random -Maximum 1000

$jobs=0
while ($true){
cls
$jobs=(get-job).count
get-job
if ($jobs -lt 5)
{
    

    start-job -ScriptBlock {
                                param ($j)
                                start-sleep(Get-Random -Maximum 10) 
                                return $j
                            } -ArgumentList($jobs)
    
}
else { start-sleep(5)
       get-job -State Completed|receive-job
       get-job -State Completed -HasMoreData $false|remove-job
         }

}