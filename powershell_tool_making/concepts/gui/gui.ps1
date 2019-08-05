# This demonstrates how to create a simple gui form in powershell

# Load the System.Windows.Forms class in this powershell session
Add-Type -assembly System.Windows.Forms

# Create the screen form (window)
$main_form = New-Object System.Windows.Forms.Form

# Set the title and size of the window
$main_form.Text = 'GUI for PowerShell Scripts'
$main_form.Width = 600
$main_form.Height = 150

# To make the form automatically stretch, if the elements on the form are
# out of bounds
$main_form.AutoSize = $true

#=========== elements ============#

# Create a label element on the form
$label_1 = New-Object System.Windows.Forms.Label
$label_1.Text = "Local Users: "
$label_1.Location = New-Object System.Drawing.Point(10, 10)
$label_1.AutoSize = $true
$main_form.Controls.Add($label_1)

# Create a dropdown list and fill it with a list of local user accounts
$combo_box = New-Object System.Windows.Forms.ComboBox
$combo_box.Width = 300
$users = Get-LocalUser

foreach($user in $users){
    $combo_box.Items.Add($user.Name)
}

$combo_box.Location = New-Object System.Drawing.Point(10,40)
$main_form.Controls.Add($combo_box)

# Label 2 - last password set label
$label_2 = New-Object System.Windows.Forms.Label
$label_2.Text = "Last Password Set: "
$label_2.Location = New-Object System.Drawing.Point(335, 10)
$label_2.AutoSize = $true
$main_form.Controls.Add($label_2)

# Label 3 - last password set
$label_3 = New-Object System.Windows.Forms.Label
$label_3.Text = ""
$label_3.Location = New-Object System.Drawing.Point(440, 10)
$label_3.AutoSize = $true
$main_form.Controls.Add($label_3)

# Button that displays the last time the password was set
$button_1 = New-Object System.Windows.Forms.Button
$button_1.Location = New-Object System.Drawing.Point(335, 40)
$button_1.Size = New-Object System.Drawing.Size(120, 20)
$button_1.Text = "Check"
$main_form.Controls.Add($button_1)

$button_1.Add_Click(
    {
        $label_3.Text = Get-LocalUser $combo_box.SelectedItem | fl -Property PasswordLastSet
    }
)

#========== end elements =========#

# Finally, display the form on the screen
$main_form.ShowDialog()