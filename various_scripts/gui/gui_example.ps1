# Gui example

# Include System.Windows.Forms class
Add-Type -assembly System.Windows.Forms

# Create the screen form (window)
$main_form = New-Object System.Windows.Forms.Form

# Set the title and size of the window
$main_form.Text = 'GUI Example 1'
$main_form.Width = 600
$main_form.Height = 400

# Allow the form to stretch for out-of-bounds elements
$main_form.AutoSize = $true

# Display the form on the screen
$main_form.ShowDialog()


