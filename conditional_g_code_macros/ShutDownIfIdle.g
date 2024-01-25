
if ((state.status=="idle") || (state.status=="busy")) && (state.atxPower == true)
		echo "machine is idle and power is on"
		if  global.ShutDownCounterRunning = false
			set global.ShutDownCounterRunning = true
			set global.idleShutdownLimit = state.upTime + global.idleShutdownTime
			echo "timer set"
		else
			if (state.upTime > global.idleShutdownLimit) 
				M291 P"Forced power down in 5 seconds" R"Shutting down" S0 T5
				M81;turn off ATX
			else
				echo "Shutdown active but still counting down"
else
	set global.ShutDownCounterRunning = false
	set global.idleShutdownLimit = state.upTime + global.idleShutdownTime
	echo "shutdown timer reset"
	