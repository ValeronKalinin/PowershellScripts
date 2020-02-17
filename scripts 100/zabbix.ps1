 $cred=Get-Credential
 #$term=Get-ADComputer -Filter {name -like "1c-mst*" -and  name -notlike "1C-MSTS" -or  name -like "1c-msl*"  } | select name 
 $servers=$null;$servers=@()
 $value=$null
 cls
 Write-Host "Введите имя сервераили "N" для выхода:"  #`n 
 while ($value -ne "N")
 {

 $value= Read-Host
 
 if ($value -ne "N"){
 $servers+=$value
} 
 }
 $Servers
 
 #= Get-ADComputer -Filter {name -like "*dhcp*"  } | select name 
  
 foreach ($t in $servers)

 {
 $t.Trim()
 $computername=$t.Trim()
 #$computername=$t

 Write-Host "Копирование конфигурации"
 
 Copy-Item -Path "\\core-fs-1\Distributives\zabbix\*"  -Destination "\\$computername\c$\Distr\zabbix_agent\" -Recurse -Force -Confirm:$false  #-Credential $cred


 Invoke-Command -ComputerName $computername -ScriptBlock{
                                                                        
                                                        $state=get-Service 'Zabbix Agent'
                                                            if ($state -eq $null)
                                                            {
                                                              cmd.exe /c "C:\Distr\zabbix_agent\install.cmd" 
                                                            }
                                                        } -Credential $cred
 Write-Host "Остановка службы"
 Invoke-Command -ComputerName $computername -ScriptBlock{
                                                          Stop-Service 'Zabbix Agent'
                                                          } -Credential $cred


 
 Write-Host "Запуск службы"
 Invoke-Command -ComputerName $computername -ScriptBlock{Start-Service 'Zabbix Agent'} -Credential $cred
 Invoke-Command -ComputerName $computername -ScriptBlock{get-Service 'Zabbix Agent'} -Credential $cred

 }