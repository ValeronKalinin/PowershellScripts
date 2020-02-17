Get-DnsServerZone | Where {$_.ZoneType -eq "Primary" -and $_.IsAutoCreated -eq $false} | Foreach {
	$name = $_.ZoneName
	Get-DnsServerResourceRecord -ZoneName $name  | Where {$_.RecordType -match "^A|PTR$"} | 
		Select @{n="HostName";e={$_.HostName + ".$name"}},@{n="Record";e={
			if ($_.RecordType -eq "A"){ 
				$_.RecordData.IPv4Address | Where {$_}
			}
			if ($_.RecordType -eq "PTR"){
				$_.RecordData.PtrDomainName | Where {$_}
			}
		}} | Export-Csv "C:\Users\v.kalinin\Desktop\dns\$name.csv" -NoTypeInformation -UseCulture -Encoding UTF8
}