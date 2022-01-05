;start.g - Run at the start of each print
M118 S"Running start.g"
if (state.atxPower!=true)
	M80 ; turn on power to motors & heaters
	G4 S3 ; wait a few seconds to let power stabilise
G4 S0.5 ; wait 1/2 second
set global.Cancelled = false
if sensors.filamentMonitors[0].status="ok"
	set global.filamentDistance = 0 ; reset filament sensor extrusion distance after tripping
else
	abort "Filament sensor shows no filament loaded.  Print aborted"
M42 P5 S1; turn on LED strip driven by P5 output
if {state.gpOut[5].pwm==1} ; check if output activated and report
	M118 S"LED strip is on"
else
	M118 S"LED strip output did not activate"
if !(sensors.filamentMonitors[0].status="ok")
	abort "No filament detected by sensor - print cancelled"
	
M98 P"0:/sys/setDefaultProbePoints.g" ; reset probe points
M118 S"exiting start.g"