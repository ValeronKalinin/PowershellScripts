#Р—Р°РїСѓСЃРє СЃРµРєСѓРЅРґРѕРјРµСЂР°
$Timer = [System.Diagnostics.Stopwatch]::StartNew()
$Timer1 = [System.Diagnostics.Stopwatch]::StartNew()
$Timer.Start()


#$tempObj = New-Object psobject
#РҐСЌС€С‚Р°Р±Р»РёС†Р° РґР»СЏ С…СЂР°РЅРµРЅРёСЏ  РїР°СЂ TRAN_ID - РІСЂРµРјСЏ
$table = @{ } 
$tablelong = @{ } 
#РҐСЂР°РЅРёРј РѕР±СЂР°Р±РѕС‚Р°РЅРЅС‹Рµ РґР°РЅРЅС‹Рµ РїРѕ РєР°Р¶РґРѕР№ СЃРµРєСѓРЅРґРµ
$result = @{ }
#РЈСЃСЂРµРґРЅРµРЅРЅС‹Рµ РґР°РЅРЅС‹Рµ РїРѕ РєР°Р¶РґРѕР№ СЃРµРєСѓРЅРґРµ
$Data = @()
#РїРµСЂРµРјРµРЅРЅР°СЏ РґР»СЏ С…СЂР°РЅРµРЅРёСЏ РґР°РЅРЅС‹С… С‚Р°Р№РјРµСЂР°
$seconds = $null

# Р¤Р°Р№Р»  Р»РѕРіР° РєРѕС‚РѕСЂС‹Р№ Р±СѓРґРµРј РїР°СЂСЃРёС‚СЊ
$Path_in="C:\Users\vk\Desktop\eq\ineq.txt"
#Р¤Р°Р№Р» РІС‹РІРѕРґР° РєСѓРґР° Р±СѓРґРµРј РїРёСЃР°С‚СЊ РѕР±СЂР°Р±РѕС‚Р°РЅРЅС‹Рµ РґР°РЅРЅС‹Рµ
$Path_out="C:\Users\vk\Desktop\eq\inEQ.out"

$reader = [System.IO.File]::OpenText($Path_in)
while (!($reader.EndOfStream)) {
   
    #Р§РёС‚Р°РµРј СЃС‚СЂРѕРєСѓ
    $line = $reader.ReadLine()
        
        $direction =    $line.split(":")[2].Split(";")[-1]
        $time = $line.split(";")[0]
        $TRAN_ID = $line.split(" ")[2].split(";")[0]
        $seconds_now = $time.split(".")[0].split(":")[2] 
        
        # РљРѕРіРґР° РєРѕРЅС‡Р°РµС‚СЃСЏ СЃРµРєСѓРЅРґР° СЃС‡РёС‚Р°РµРј РґР°РЅРЅС‹Рµ (СЃСЂРµРґРЅРµРµ, РјРµРґРёР°РЅСѓ, 99 РїРµСЂС†РµРЅС‚РёР»СЊ, РјР°РєСЃРёРјСѓРј, РєРѕР»РёС‡РµСЃС‚РІРѕ)
        
    if ($seconds -ne $seconds_now -and $seconds -ne $null) {
         
        $Timer3.Stop()
        write-host $Timer3.Elapsed
        #$Timer2 = [System.Diagnostics.Stopwatch]::StartNew()
        #$Timer2.Start()  
        <##>
        $tempObj = @{}
        $summ = $null 
        # РњР°РєСЃРёРјР°Р»СЊРЅР°СЏ Р·Р°РґРµСЂР¶РєР° РІ РњРРљР РћРЎР•РљРЈРќР”РђРҐ
        $max = 0 
        foreach ($r in $result.Values) {
                
            if ($max -lt $r) { $max = $r }
                
            $summ += $r 
        } 
        # РљРѕР»РёС‡РµСЃС‚РІРѕ
        $count = $result.Count 
        # РЎСЂРµРґРЅСЏСЏ Р·Р°РґРµСЂР¶РєР° РІ РњРРљР РћРЎР•РљРЈРќР”РђРҐ                      
        $average = [math]::Round(($summ / $count), 2)    
        # РЎС‡РёС‚Р°РµРј РјРµРґРёР°РЅСѓ
        $Mediandata =  Sort-Object -InputObject $result.Values 
        $MedianValue = $Mediandata[[math]::Round($count / 100 * 50)]

        # 99 РїСЂРѕС†РµРЅС‚РёР»СЊ
        $P99 = $null
        $P99 = $Mediandata[[math]::Round($count / 100 * 99)]
            
        # РЎРѕР±РёСЂР°РµРј СЃС‚СЂРѕРєСѓ РѕС‚С‡РµС‚пїЅ
        
        $tempObj["Time"]=$line.split(";")[0].split(".")[0]
        $tempObj["Average"]=$average 
        $tempObj["Median"]=$MedianValue 
        $tempObj["P99"]=$P99
        $tempObj["Count"]=$count
        $tempObj["Max"]=$max

        $obj=New-Object -TypeName psobject -Property $tempObj
        # СЃРѕС…СЂР°РЅСЏРµРј СЃС‚СЂРѕРєСѓ РѕС‚С‡РµС‚Р°
        $Data += $obj
        $result = @{ }

        # РўР°Р№РјРµСЂ РґР»СЏ Р°РЅР°Р»РёР·Р° СЃРєРѕСЂРѕСЃС‚Рё РѕР±СЂР°Р±РѕС‚РєРё 1 СЃРµРєСѓРЅРґС‹ Р»РѕРіР°
        #$Timer2.Stop()
        #write-host $Timer2.Elapsed 

        $Timer3 = [System.Diagnostics.Stopwatch]::StartNew()
        $Timer3.Start() 
    }
       
    
    # Р’ СЌС‚РѕР№ СЃРµРєС†РёРё СЏ РїРёС€Сѓ РІ РҐРµС€С‚Р°Р±Р»РёС†Сѓ РґР°РЅРЅС‹Рµ РµСЃР»Рё РЅР°С€РµР» СЃС‚СЂРѕРєСѓ INPUT
    if ( $direction -eq "INPUT") {
        
        $table[$TRAN_ID] = $time
       
    }
    
   
    if ($direction -eq "OUTPUT" -and ($tstart=$table[$TRAN_ID])) {    

        #$tstart = $table[$TRAN_ID]

        #if ($tstart -ne $null) {
            
            $tfinish = $time 
                
            #  РЎС‡РёС‚Р°РµРј Р·Р°РґРµСЂР¶РєСѓ
            $latency = [math]::Round([math]::Abs(  ([timespan]$tstart).TotalMilliseconds - ([timespan]$tfinish).TotalMilliseconds), 3) * 1000
                
            # РџРёС€РµРј РІ С‚Р°Р±Р»РёС†Сѓ Р·Р°РґРµСЂР¶РєСѓ РІ РєРѕРЅРєСЂРµС‚РЅС‹Р№ РјРѕРјРµРЅС‚ РІСЂРµРјРµРЅРё (РІСЂРµРјСЏ OUTPUT)
            $result[$tstart] = $latency
                
            # Р Р°СЃРєРѕРјРµРЅС‚РёСЂРѕРІР°С‚СЊ РґР»СЏ РїСЂРѕРІРµСЂРєРё РіР»Р°Р·Р°РјРё 
            #write-host $testID " " $table.($TRAN_ID.trim()) " "  $time 
                
            #РЈРґР°Р»СЏСЋ РёР· РҐРµС€С‚Р°Р±Р»РёС†С‹ Р·Р°РїРёСЃСЊ
            $table.Remove($TRAN_ID)
    
    }

    $seconds = $seconds_now
     
}
$Timer.Stop()
write-host $Timer.Elapsed $Data.count $maxtablecount
$Data | Export-Csv -Path $Path_out -Encoding UTF8 -NoTypeInformation  
