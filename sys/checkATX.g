if (state.atxPower = false) || (state.deferredPowerDown = true)
	M80
	if result != 0
		abort "Could not power up - aborting print"
	else
		echo "Powering up"
		while true
			if (boards[0].vIn.current < 24)
				echo "Waiting for voltage to reach 24v  .. Currently - " ^ boards[0].vIn.current ^ "v"
				G4 P500
			else
				echo "System at full power : " ^ boards[0].vIn.current ^ "v"
				echo "Thunderbirds are go!"
				break
			if iterations = 20
				break
				
if (boards[0].vIn.current < 24)
	abort "VIN under voltage : " ^ boards[0].vIn.current ^ "v"