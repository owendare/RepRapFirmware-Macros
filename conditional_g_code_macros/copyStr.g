; takes 3 parameters
; A - String to copy
; B - Start position
; C - Number of charectors
var result = ""
var count = 0
var string = vector(#param.A,null)
while iterations < #var.string
	if (iterations >= param.B)
	set var.result = var.result ^ var.string[iterations]