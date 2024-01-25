echo "line 1"

echo "line 2"

var test = 1

; check that we have power
if (state.atxPower != null)
	if state.atxPower = false
		M80 ; turn on ATX power
		G4 S3 ; wait a few seconds to power up

;echo "check voltage"
if (boards[0].vIn.current) < (20)
	abort "ABORT: Voltage too low for motor movement"

while iterations < 200
	if mod(iterations,2)=0
		set var.test = boards[0].vIn.max
	else
		set var.test = boards[0].vIn.min
	
;commented line before error

echo test

echo "line 17"