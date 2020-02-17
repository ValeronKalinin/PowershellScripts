$servers=(Get-ADComputer -Filter {(name -like "*core*") -and (OperatingSystem  -like "*windows server*") } -Properties *|
 select name, OperatingSystem, PasswordLastSet, description| where PasswordLastSet -ge (get-date).AddDays(-30)| where description -NotLike "*failover*")


$watch = [System.Diagnostics.Stopwatch]::StartNew()
$watch.Start() #Запуск таймера

foreach ($server in $servers)
            {
                    
                   $connection= New-Object System.Net.Sockets.TCPClient -ArgumentList $server.name, 5985 
                    if (!$iar.AsyncWaitHandle.WaitOne($timeout,$false)){
                    $tcpclient.Close()
                    }
                    
                    if ($connection.Connected) {
    Write-Host "Success" $server.name
                                                }
                    
            }
#Get-Job|Wait-Job|Receive-Job |Remove-Job

Write-Host $watch.Elapsed #Время выполнения 1 поток
return  $watch.Elapsed