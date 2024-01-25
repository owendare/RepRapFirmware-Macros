;check-stops.g
; check all axis endstops and move away if triggered

while iterations < #inputs
	echo inputs[iterations].axesRelative
	G4 s1



while iterations < #sensors.endstops

	if sensors.endstops[iterations].triggered
		echo "Endstop " ^ iterations " is triggered"
		abort