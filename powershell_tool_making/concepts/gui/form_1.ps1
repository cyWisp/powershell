# Load the windows forms class into the session
Add-Type -assembly System.Windows.Forms

# Create the main form and set title, height and width properties
$main_form = New-Object System.Windows.Forms.Form
$main_form.Text = 'Just a Test'
$main_form.Width = 800
$main_form.Height = 600

# Allow the form to stretch and be resized when necessary
$main_form.AutoSize = $true



# Display the form on the screen
$main_form.ShowDialog()


