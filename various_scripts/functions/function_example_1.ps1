# Functions example

function hello_world {
    write-host("Hello, world!")
}

function hello_user($input_string){
    write-host("hello $input_string- how are you?")
}

hello_world

$user_input = Read-Host("What is your name? ")
hello_user($user_input)

