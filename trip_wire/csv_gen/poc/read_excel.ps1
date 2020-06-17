# S:\repos\personal\powershell\trip_wire\csv_gen

# select excel file you want to read
$file = "S:\repos\personal\powershell\trip_wire\csv_gen\poc\test_template.xlsx"
$sheet_name = "Ports and Services"

# create new excel COM object
$excel = New-Object -com Excel.Application

# open excel file
$wb = $excel.workbooks.open($file)
$sheet = $wb.Worksheets.Item($sheet_name) 

# select total rows
$row_max = ($sheet.UsedRange.Rows).Count

# create new object with field names
$node_data = New-Object -TypeName psobject
#$node_data | Add-Member -MemberType NoteProperty -Name os -Value $null
$node_data | Add-Member -MemberType NoteProperty -Name protocol -Value $null
$node_data | Add-Member -MemberType NoteProperty -Name port -Value $null
$node_data | Add-Member -MemberType NoteProperty -Name description -Value $null
$node_data | Add-Member -MemberType NoteProperty -Name justification -Value $null
$node_data | Add-Member -MemberType NoteProperty -Name documentation -Value $null

# create empty arrayList
$my_array = @()
# create output file
$output_file = new-item -type file "./test_out.csv"

for ($i = 9; $i -le $row_max; $i++){
    $temp = $node_data | Select-Object *

    # read data from cells
    $temp.os = "Windows"
    $temp.protocol = $sheet.Cells.Item($i, 3).Text
    $temp.port = $sheet.Cells.Item($i, 2).Text
    $temp.description = $sheet.Cells.Item($i, 5).Text
    $temp.justification = $sheet.Cells.Item($i, 6).Text
    $temp.documentation = $sheet.Cells.Item($i, 8).Text


    #Write-Host("ip address: $($temp.ip_address)")
    $data = "$($temp.protocol), $($temp.port), $($temp.description), $($temp.justification), $($temp.documentation)`n"
    Add-Content -Path $output_file -Value $data

    $my_array += $temp
}

# foreach ($x in $my_array) {
#     write-host($x)
# }

$excel.Quit()

# force stop Excel process
Stop-Process -Name Excel -Force