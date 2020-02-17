 sap-pd-bo-1 
 sap-pd-cc-1 
 sap-pd-cc-2 
 sap-pd-sq-1 
 sap-pd-sq-2 
 sap-pd-df-1 
 sap-pd-df-2 
 sap-qs-bo-1 
 sap-qs-cc-1 
 sap-qs-sq-1 
 sap-qs-df-1 

 New-NetFirewallRule -DisplayName "80,443,TCP" -Direction Inbound -Protocol TCP -LocalPort 80,443 -Action Allow; New-NetFirewallRule -DisplayName "80,443,UDP" -Direction Inbound -Protocol UDP -LocalPort 80,443 -Action Allow;New-NetFirewallRule -DisplayName "80,443,TCP" -Direction Outbound -Protocol TCP -LocalPort 80,443 -Action Allow; New-NetFirewallRule -DisplayName "80,443,UDP" -Direction Outbound -Protocol UDP -LocalPort 80,443 -Action Allow
