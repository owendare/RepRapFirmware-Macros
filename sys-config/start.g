;start.g - Run at the start of each print
M118 S"Running start.g"
G4 S0.5 ; wait 1/2 second
M42 P5 S1; turn on LED strip driven by P5 output
if {state.gpOut[5].pwm==1} ; check if output activated and report
	M118 S"LED strip is on"
else
	M118 S"LED strip output did not activate"