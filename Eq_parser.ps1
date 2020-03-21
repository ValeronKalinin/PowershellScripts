#Запуск секундомера
$Timer = [System.Diagnostics.Stopwatch]::StartNew()
#Хэштаблица для хранения  пар TRAN_ID - время
$table = @{ } 
#Храним обработанные данные по каждой секунде
$result = @{ }
#Усредненные данные по каждой секунде
$Data = @()
#переменная для хранения данных таймера
$seconds = $null

# Файл  лога который будем парсить
$Path_in="C:\latency\Equalizer_0.2020031610.log"
#Файл вывода куда будем писать обработанные данные
$Path_out="C:\latency\latency.csv"


$reader = [System.IO.File]::OpenText($Path_in)
while (!($reader.EndOfStream)) {
    #Читаем строку
    $line = $reader.ReadLine()
    
    $time = $line.split(";")[0]
    #$testID=(($line.split(";").split(",") | Select-String -Pattern "TRAN_ID") -split ":")[1]
    $testID = $line.split(" ")[2].split(";")[0]
    $seconds_now = $time.split(".")[0].split(":")[2] 

    # Когда кончается секунда считаем данные (среднее, медиану, 99 перцентиль, максимум, количество)
    <#
    if ($seconds -ne $seconds_now -and $seconds -ne $null) {
        $tempObj = New-Object psobject
        #$tempObj=@{}
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
        $Mediandata = $result.Values | sort
        if ($count % 2) {

            $MedianValue = $Mediandata[[math]::Floor($count / 2)]

        }

        else {
               
            $MedianValue = ($Mediandata[$Count / 2], $Mediandata[$count / 2 - 1] | measure -Average).average
        } 

        # 99 процентиль
        $P99 = $null
        $P99 = $Mediandata[[math]::Round($count / 100 * 99)]
            
        # Собираем строку отчета
        $tempObj | Add-Member -MemberType NoteProperty -name  "Time" -Value $line.split(";")[0].split(".")[0]
        $tempObj | Add-Member -MemberType NoteProperty -name  "Average" -Value $average 
        $tempObj | Add-Member -MemberType NoteProperty -name  "Median" -Value $MedianValue
        $tempObj | Add-Member -MemberType NoteProperty -name  "P99" -Value $P99
        $tempObj | Add-Member -MemberType NoteProperty -name  "Count" -Value $count
        $tempObj | Add-Member -MemberType NoteProperty -name  "Max" -Value $max 
        
        ##$tempObj["Time"]=$line.split(";")[0].split(".")[0]
        ##$tempObj["Average"]=$average 
        ##$tempObj["Median"]=$MedianValue 
        ##$tempObj["P99"]=$P99
        ##$tempObj["Count"]=$count
        ##$tempObj["Max"]=$max



        # сохраняем строку отчета
        $Data += $tempObj 
        $result = @{ }

        # Таймер для анализа скорости обработки 1 секунды лога
        #$Timer.Stop()
        #write-host $Timer.Elapsed
        #$Timer = [System.Diagnostics.Stopwatch]::StartNew()
        #$Timer.Start()

    }#>
    
    if ($null -ne $testID) {
    
        $TRAN_ID = $line.split(" ")[2].split(";")[0]
    }

    else { $TRAN_ID = $null }
    

    # В этой секции я пишу в Хештаблицу данные если нашел строку INPUT
    if ( $line.Contains("INPUT") -eq $true) {
    
        $table[$TRAN_ID.trim()] = $time.Trim()
                
    }
    
    # В этой секции если нашел строку OUTPUT 
    if ($line.Contains("OUTPUT") -eq $true ) {    
            
        $tstart = $table[$TRAN_ID.trim()]

        if ($tstart -ne $null) {
            $tfinish = $time 
                
            #  Считаем задержку
            $latency = [math]::Round([math]::Abs(  ([timespan]$tstart).TotalMilliseconds - ([timespan]$tfinish).TotalMilliseconds), 3) * 1000
                
            # Пишем в таблицу задержку в конкретный момент времени (время OUTPUT)
            $result[$tstart] = $latency
                
            # Раскоментировать для проверки глазами 
            write-host $testID " " $table.($TRAN_ID.trim()) " "  $time 
                
            #Удаляю из Хештаблицы запись
            $table.Remove($TRAN_ID.trim())
        }
    
    }
        
    $seconds = $seconds_now
        
}
