$vc = "8bus-vc.orglot.office",	"avln-vc-te-01.orglot.office",	"board-prod-vc.orglot.office",	"board-vc.orglot.office",	"cloud.orglot.office",	"cloud2.orglot.office",	"core-vc-ltt-01.orglot.office",	"dwh-te-vc-01",	"idf-vc.orglot.office ",	"sas-vc.orglot.office",	"sms-vc.orglot.office"
$i = @()
foreach ($v in $vc)
{
$i+=Test-Connection -ComputerName $v.trim() -Count 1 
}