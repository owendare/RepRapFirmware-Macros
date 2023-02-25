;check BL Touch
if sensors.probes[0].value[0]=1000 ; if probe is in error state
	echo "Probe in error state- resetting"
	M280 P0 S160 ; reset BL Touch
	G4 S0.5
if state.gpOut[0].pwm=0.03
	echo "Probe ia already deployed - retracting"
	M280 P0 S80 ; retract BLTouch
	G4 S0.5

if sensors.endstops[2].triggered
	echo "Probe ia already triggered - resetting"
	M280 P0 S160 ; reset BL Touch
	G4 S0.5
