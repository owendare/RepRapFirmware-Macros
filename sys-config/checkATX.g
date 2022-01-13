if (state.atxPower = false) || (state.deferredPowerDown=1)
	M80
	if result != 0
		abort "Could not power up - aborting print"
	else
		echo "Powering up"
	G4 S1
if (boards[0].vIn.current < 24)
	abort "VIN under voltage : " ^ boards[0].vIn.current ^ "v"