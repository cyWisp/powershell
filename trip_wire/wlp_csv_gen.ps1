# | ========== parameters =========== |
param (
    [Parameter(Mandatory=$true)][String]$os,
    [Parameter(Mandatory=$true)][String]$excel_file,
    [String]$s_name
)

$node_data = New-Object -TypeName psobject
$node_data | Add-Member -MemberType NoteProperty -Name os -Value $null
$node_data | Add-Member -MemberType NoteProperty -Name protocol -Value $null
$node_data | Add-Member -MemberType NoteProperty -Name port -Value $null
$node_data | Add-Member -MemberType NoteProperty -Name service -Value $null
$node_data | Add-Member -MemberType NoteProperty -Name description -Value $null
$node_data | Add-Member -MemberType NoteProperty -Name justification -Value $null
$node_data | Add-Member -MemberType NoteProperty -Name documentation -Value $null

function create_output_file {
    # create output file
    $remove_path = $excel_file.SubString($excel_file.LastIndexOf("\") + 1)
    $output_file_name = ".\WLP-$($remove_path -Replace 'xlsx', 'csv')"
    
    return $output_file_name
}

# | ========== variables =========== |

# Create a new excel COM object
$excel_object = New-Object -com Excel.Application
$wb = $excel_object.workbooks.open($(Resolve-Path $excel_file))

# # Default sheet name if not provided
if (!$s_name) {
    $sheet = $wb.Worksheets.Item("Ports and Services")
} else {
    $sheet = $wb.Worksheets.Item($s_name)
}

# get number of rows in document
$row_max = ($sheet.UsedRange.Rows).Count
write-host($row_max)

# | ========== Execution =========== |

# Format output file name
$output_file_name = create_output_file
$csv_file = new-item -type file $output_file_name

for ($i = 9; $i -le $row_max; $i++) {
    $new_object = $node_data | Select-Object *
    
    if ($new_object.protocol = $sheet.Cells.Item($i, 3).Text){
        $new_object.os = $os
        $new_object.protocol = $sheet.Cells.Item($i, 3).Text
        $new_object.port = $sheet.Cells.Item($i, 2).Text
        $new_object.service = $sheet.Cells.Item($i, 1).Text
        $new_object.description = $sheet.Cells.Item($i, 5).Text
        $new_object.justification = $sheet.Cells.Item($i, 6).Text
        $new_object.documentation = $sheet.Cells.Item($i, 8).Text


        $data = "$($new_object.os), $($new_object.protocol), $($new_object.port), $($new_object.service),$($new_object.description), $($new_object.justification), $($new_object.documentation)`n"
        Add-Content -Path $csv_file -Value $data
    }
}

# Quit out of the excel COM object instance
$excel_object.Quit()












