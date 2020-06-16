# S:\repos\personal\powershell\trip_wire\csv_gen

# select excel file you want to read
$file = "S:\repos\personal\powershell\trip_wire\csv_gen\nodes.xlsx"
$sheet_name = "Sheet1"

# create new excel COM object
$excel = New-Object -com Excel.Application

# open excel file
$wb = $excel.workbooks.open($file)
$sheet = $wb.Worksheets.Item($sheet_name) 

# select total rows
$row_max = ($sheet.UsedRange.Rows).Count

# create new object with field names
$node_data = New-Object -TypeName psobject
$node_data | Add-Member -MemberType NoteProperty -Name ip_address -Value $null
$node_data | Add-Member -MemberType NoteProperty -Name protocol -Value $null
$node_data | Add-Member -MemberType NoteProperty -Name port -Value $null
$node_data | Add-Member -MemberType NoteProperty -Name mac -Value $null
$node_data | Add-Member -MemberType NoteProperty -Name service -Value $null
$node_data | Add-Member -MemberType NoteProperty -Name dns -Value $null
$node_data | Add-Member -MemberType NoteProperty -Name nb -Value $null

# create empty arrayList
$my_array = @()
# create output file
$output_file = new-item -type file "./test_out.csv"

for ($i = 2; $i -le $row_max; $i++){
    $temp = $node_data | Select-Object *

    # read data from cells
    $temp.ip_address = $sheet.Cells.Item($i, 1).Text
    $temp.protocol = $sheet.Cells.Item($i, 2).Text
    $temp.port = $sheet.Cells.Item($i, 3).Text
    $temp.mac = $sheet.Cells.Item($i, 4).Text
    $temp.service = $sheet.Cells.Item($i, 5).Text
    $temp.dns = $sheet.Cells.Item($i, 6).Text
    $temp.nb = $sheet.Cells.Item($i, 7).Text

    #Write-Host("ip address: $($temp.ip_address)")
    $data = "$($temp.ip_address), $($temp.protocol), $($temp.port), $($temp.mac), $($temp.service), $($temp.dns), $($temp.nb)`n"
    Add-Content -Path $output_file -Value $data

    $my_array += $temp
}

# foreach ($x in $my_array) {
#     write-host($x)
# }

$excel.Quit()

# force stop Excel process
Stop-Process -Name Excel -Force