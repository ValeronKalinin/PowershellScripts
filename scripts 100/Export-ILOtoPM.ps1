$XLSpath = "C:\Users\v.kalinin\Desktop\WorkScripts\scripts 100\PM-Exp.xlsx"
$CSVPath_mod = "C:\Users\v.kalinin\Desktop\WorkScripts\scripts 100\pm-temp.csv"
$OutFile = "C:\Users\v.kalinin\Desktop\WorkScripts\scripts 100\pm-iLo.txt"

if (Test-Path $XLSpath) {
    if (Test-Path $CSVPath_mod) {
        Remove-Item $CSVPath_mod
    }
    $objExcel = New-Object -comobject Excel.Application
    $objExcel.displayalerts=$False
    $objWorkbook = $objExcel.Workbooks.Open($XLSpath)
    $objWorksheet = $objWorkbook.Sheets.Item('Sheet1')
    $objWorksheet.SaveAs($CSVPath_mod, 6)
    $objExcel.Workbooks.Close()
    $objExcel.Quit()
    $objExcel = $null
        
    $filedata = Get-Content -Path $CSVPath_mod
    
    $columns = $filedata[0].Split(',')

    for ($i = 1; $i -lt $filedata.Count; $i++) {
        $data = $filedata[$i].Split(',')
        "" | Out-File $OutFile -Append -Encoding utf8
        "$($columns[0]): $($data[0])" | Out-File $OutFile -Append -Encoding utf8
        "$($columns[1]): $($data[1])" | Out-File $OutFile -Append -Encoding utf8
        "$($columns[2]): $($data[2])" | Out-File $OutFile -Append -Encoding utf8
        "$($columns[3]): $($data[3])" | Out-File $OutFile -Append -Encoding utf8
        "$($columns[4]): $($data[4])" | Out-File $OutFile -Append -Encoding utf8
        "$($columns[5]): $($data[5])" | Out-File $OutFile -Append -Encoding utf8
        "$($columns[6]): $($data[6])" | Out-File $OutFile -Append -Encoding utf8
    }

    if (Test-Path $CSVPath_mod) {
       Remove-Item $CSVPath_mod 
    }
    
}
else {
    Write-Host "Нет XLS файла по ожидаемому пути: $XLSpath"
}