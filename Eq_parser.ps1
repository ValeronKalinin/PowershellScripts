#Запуск секундомера
$Timer = [System.Diagnostics.Stopwatch]::StartNew()
$Timer1 = [System.Diagnostics.Stopwatch]::StartNew()
$Timer.Start()


#$tempObj = New-Object psobject
#Хэштаблица для хранения  пар TRAN_ID - время
$table = @{ } 
$tablelong = @{ } 
#Храним обработанные данные по каждой секунде
$result = @{ }
#Усредненные данные по каждой секунде
$Data = @()
#переменная для хранения данных таймера
$seconds = $null

# Файл  лога который будем парсить
$Path_in="C:\Users\vk\Desktop\eq\ineq.txt"
#Файл вывода куда будем писать обработанные данные
$Path_out="C:\Users\vk\Desktop\eq\inEQ.out"

$reader = [System.IO.File]::OpenText($Path_in)
while (!($reader.EndOfStream)) {
   
    #Читаем строку
    $line = $reader.ReadLine()
        
        $direction =    $line.split(":")[2].Split(";")[-1]
        $time = $line.split(";")[0]
        $TRAN_ID = $line.split(" ")[2].split(";")[0]
        $seconds_now = $time.split(".")[0].split(":")[2] 
        
        # Когда кончается секунда считаем данные (среднее, медиану, 99 перцентиль, максимум, количество)
        
    if ($seconds -ne $seconds_now -and $seconds -ne $null) {
         
        $Timer3.Stop()
        write-host $Timer3.Elapsed
        #$Timer2 = [System.Diagnostics.Stopwatch]::StartNew()
        #$Timer2.Start()  
        <##>
        $tempObj = @{}
        $summ = $null 
        # Максимальная задержка в МИКРОСЕКУНДАХ
        $max = 0 
        foreach ($r in $result.Values) {
                
            if ($max -lt $r) { $max = $r }
                
            $summ += $r 
        } 
        # Количество
        $count = $result.Count 
        # Средняя задержка в МИКРОСЕКУНДАХ                      
        $average = [math]::Round(($summ / $count), 2)    
        # Считаем медиану
        $Mediandata =  Sort-Object -InputObject $result.Values 
        $MedianValue = $Mediandata[[math]::Round($count / 100 * 50)]

        # 99 процентиль
        $P99 = $null
        $P99 = $Mediandata[[math]::Round($count / 100 * 99)]
            
        # Собираем строку отчет�
        
        $tempObj["Time"]=$line.split(";")[0].split(".")[0]
        $tempObj["Average"]=$average 
        $tempObj["Median"]=$MedianValue 
        $tempObj["P99"]=$P99
        $tempObj["Count"]=$count
        $tempObj["Max"]=$max

        $obj=New-Object -TypeName psobject -Property $tempObj
        # сохраняем строку отчета
        $Data += $obj
        $result = @{ }

        # Таймер для анализа скорости обработки 1 секунды лога
        #$Timer2.Stop()
        #write-host $Timer2.Elapsed 

        $Timer3 = [System.Diagnostics.Stopwatch]::StartNew()
        $Timer3.Start() 
    }
       
    
    # В этой секции я пишу в Хештаблицу данные если нашел строку INPUT
    if ( $direction -eq "INPUT") {
        
        $table[$TRAN_ID] = $time
       
    }
    
   
    if ($direction -eq "OUTPUT" -and ($tstart=$table[$TRAN_ID])) {    

        #$tstart = $table[$TRAN_ID]

        #if ($tstart -ne $null) {
            
            $tfinish = $time 
                
            #  Считаем задержку
            $latency = [math]::Round([math]::Abs(  ([timespan]$tstart).TotalMilliseconds - ([timespan]$tfinish).TotalMilliseconds), 3) * 1000
                
            # Пишем в таблицу задержку в конкретный момент времени (время OUTPUT)
            $result[$tstart] = $latency
                
            # Раскоментировать для проверки глазами 
            #write-host $testID " " $table.($TRAN_ID.trim()) " "  $time 
                
            #Удаляю из Хештаблицы запись
            $table.Remove($TRAN_ID)
    
    }

    $seconds = $seconds_now
     
}
$Timer.Stop()
write-host $Timer.Elapsed $Data.count $maxtablecount
$Data | Export-Csv -Path $Path_out -Encoding UTF8 -NoTypeInformation  
