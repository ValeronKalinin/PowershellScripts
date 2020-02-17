$i=1
$res=@()
while ($i-le 11000)
{

                    if ((get-job).count -lt 100){
                    ((get-job).count)
                    start-job   {

                                        try{
                                        New-Object Net.Sockets.TcpClient "192.168.33.187", $i 
                                            }
                                        catch{}


                    } -ArgumentList ($i)
                    }
                
                
                else {
                    $res+=Get-Job -HasMoreData $true | Receive-Job
                    Get-Job -State Completed -HasMoreData $false | Remove-Job
                    
                    ((get-job).count)
                    start-job  {
                                       
                                        try{
                                        New-Object Net.Sockets.TcpClient "192.168.33.187", $i
                                            }
                                        catch{}


            } -ArgumentList ($i)

}
$i
$i++
}



                    $res+=Get-Job|Wait-Job| Receive-Job
                    Get-Job -State Completed -HasMoreData $false | Remove-Job