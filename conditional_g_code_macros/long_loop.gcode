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
		G4 P500
		break
	echo "loop number : " ^ iterations + 1 ^ " : " ^ global.Cancelled
	if iterations > 10
		set global.Cancelled = true
	G4 P500
if global.Cancelled = true
	abort "Macro/print cancelled"