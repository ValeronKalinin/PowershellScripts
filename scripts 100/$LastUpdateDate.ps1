$windowsUpdateObject = New-Object -ComObject Microsoft.Update.AutoUpdate
$UPdate=Get-Date(($windowsUpdateObject.Results).LastInstallationSuccessDate.ToShortDateString())
$date=get-date
$lastUpdate=($date-$update).Days
return $lastUpdate




