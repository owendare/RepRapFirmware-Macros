;loops for number of times passed is S parameter
var count=0 ; initialise variable
if !exists(param.S)
	set var.count = 20
else
	set var.count = param.S
while iterations < var.count
	G4 P100
	if global.Cancelled = true
		echo "should be cancelled"
		break
		G4 P500
	echo "loop number : " ^ iterations + 1 ^ " : " ^ global.Cancelled
	G4 P500
if global.Cancelled = true
	abort "Macro/print cancelled"