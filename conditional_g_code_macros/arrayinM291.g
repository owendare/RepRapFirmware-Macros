var myArray = {"1","2",}

while iterations < 5
	var myName = "myString"^iterations
	var {var.myString} = iterations
set var.myArray = {var.myString0,var.myString1,var.myString2,var.myString3}
echo #var.myArray[0]
M291 S4 P"Test" R"Choose button" K{var.myArray}
