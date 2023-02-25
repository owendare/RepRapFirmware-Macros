; 0:/sys/daemon.g
; runs continually in background at approximately 10 second intervals
; We have initiated an infinite loop at the start so that we can do things at intervals less than 10 seconds
; daemon.g won't be opened abain if it it still running
; everything must be indented by 2 x tabs becasue of the infinite loop at the start to allow checks at intervals less than 10 seconds
; We have created a global variable in config.g called RunDaemon
; If RunDaemon is set to "false" we exit the daemon without running anything.  However daemon.g will still try to run every 10 seconds if it exists.

if global.RunDaemon == false
	;echo "exiting daemon"
	M99 ; don't run the daemon

;HEATER CHECKS

; this section of daemon.g checks for heater faults
; RRF doesn't currently check for faults when idle but by default will shutdown during printing if temperature excursion is > 15 degrees.
; Note: temp excursion value and time  may be manually set using M570
; checking if temp is rising requires a variable.
; G4 could be used but would also delay anything else in daemon.g
; this way allows other checks to run more frequently if needed however the G4 delays inside the loop will affect the frequency of daemon.g
; We are only checking the heaters every 10 seconds.  This can be varied by changiing the global variable global.HeaterCheckInterval
; if the global variable RunHeaterChecks is false, then we skip this secton but still run the remainder of the daemon
; If ATX power isn't on then no power will go to heaters or fans, so we don't check.
while true
	if (global.RunHeaterChecks == true) && (global.RunDaemon==true) && (state.atxPower==true)
		if state.upTime < 60
			break; If uptime is < 60 seconds, break out so all fans etc have time to stabilise.

		if ((global.LastCheckTime + global.HeaterCheckInterval) > state.upTime) ; if checked in last 10 seconds escape loop and go to rest of daemon.g if present.  offset will be zero at startup via config.g
			;echo "skipping loop " ^ " " ^ state.upTime  ^ " " ^ global.LastCheckTime+global.HeaterCheckInterval
			if global.LastCheckTime-state.upTime > 60 ; uptime must have rolled over so reset off set to zero
				G10 P2 Y0
				echo "upTime has rolled over.  Heater checking reset"
				break
		else
			;add code that must be run at less than 10 second intervals here
			while iterations < #heat.heaters ; loop through all xconfigured heaters
				set global.LastTemp=heat.heaters[1].current ; Set variable to current extruder temp.
				if heat.heaters[iterations].state="tuning"
					;echo "heater " ^ iterations ^ " is tuning - no check carried out"
					continue ; don't check this heater as it is PID auto tuning
				if (heat.heaters[iterations].current) > (heat.heaters[iterations].max) ; temp is over max so emergency shutdown required
					;M41 P5 S1  ; activate output connected to externally powered latching relay here to sound alarm
					G4 S2 ; Delay to see if it's a spike on the thermistor
					if (heat.heaters[iterations].current) > (heat.heaters[iterations].max)
						M118 P0 S"heater over max temp fault detected in daemon.g.  - shutting down" L1
						M112; emergency shutdown
						M81 S1 ; turn off power when fans have turned off

				if (heat.heaters[iterations].current > 45)  &&  (heat.heaters[iterations].active > 45); no real danger at below this temp as ambient may be close to this
					;echo "heater " ^ iterations ^ " is above 45 degrees"
					if (heat.heaters[iterations].state!="off") && (heat.heaters[iterations].current > heat.heaters[iterations].active + 15) ; temp is > 15 degrees above target.
						echo "heater " ^ iterations ^ " is on or in standby - checking if temp is rising"
						set global.LastTemp=heat.heaters[iterations].current ; set the last check temp
						echo "heater " ^ iterations ^ " temp: " ^ heat.heaters[iterations].current
						G4 S3 ; wait 3 seconds
						if (heat.heaters[iterations].current > global.LastTemp + 1) ; heat is rising by more than 1 degrees in 3 seconds
							echo "heater runaway fault detected in daemon.g.  - shutting down"
							if (state.status=="processing")
								M25 ; pause print so you might be able to save it using M119
							;M41 P5 S1  ; activate output connected to externally powered latching relay here to sound alarm
							M0 ; unconditional stop.  If axes are homed and a print is being canceled will run cancel.g  otherwise will run stop.g
							M81 S1 ; turn off power when fans have turned off
						else
							;echo "heater is on or standby but temp is falling on heater " ^ iterations ^ " - no action needed"
					elif (heat.heaters[iterations].state="off") && ((heat.heaters[iterations].current) >= (fans[1].thermostatic.lowTemperature+0)) ; if heater is off and temp is greater than 50 there could be an issue
						set global.LastTemp=heat.heaters[iterations].current;
						;echo "heater " ^ iterations ^ " is off but checking if temp is rising"
						G4 S6 ; wait 5 seconds
						if (heat.heaters[iterations].current > global.LastTemp + 2) ; heat is rising by more than 2 degrees in 6 seconds
							echo "heater is off but temp is rising on heater " ^ iterations ^ "emergency shutdown"
							;M41 P5 S1  ; activate output connected to externally powered latching relay here to sound alarm
							echo "heater runaway fault detected in daemon.g.  - shutting down"
							M112; emergency shutdown
							M81 S1 ; turn off power when fans have turned off
						else
							;echo "heater " ^ iterations ^ " is off & temp is falling or stable on heater " ^ iterations ^ " - no action needed"
				else
					;echo "heater " ^ iterations ^ " is below 45 degrees so check thermistor" ;"heater is below 45 degrees so only other fault may be an open circuit thermistor which should show -275 degrees"
					if heat.heaters[iterations].current < 0 ; we probably have a thermistor fault if heater is less than 0 degrees
						echo "heater fault detected.  Thermistor may be shorted"
						M112 ; emergency shutdown
						M81 S1 ; turn off power when fans have turned off
				
				; check if we're trying to extrude at under cold extrude during a print
				if state.currentTool > -1
						if (state.status == "processing") && (heat.heaters[tools[state.currentTool].heaters[0]].current < heat.coldExtrudeTemperature)  && (move.currentMove.extrusionRate > 0)
							echo "Print is in progress and trying to extrude under cold extrude temp.  Pausing print" 
							M25
						

				;Check if water pump is running correctly
				if (iterations=1) && ((heat.heaters[1].current) > (fans[1].thermostatic.lowTemperature+0))
					if fans[1].rpm <= 500 ; Coolant pump RPM off or low
						G4 S3 ; check again in 3 seconds in case it's just spinning up
						if fans[1].rpm <= 500
							echo "Water pump fault - shutting down heaters - RPM : " ^ fans[1].rpm
							if (job.file.fileName != null) && (job.file.fileName !="")
								M25 ; pause print so you might be able to save it using M119
								M0 ; unconditional stop.  If axes are homed and a print is being canceled will run cancel.g  otherwise will run stop.g
							M98 P"0:/macros/heating/all_heaters_off.g"
							M81 S1 ; turn off power when fans have turned off
					elif (fans[1].rpm > 500) && (fans[1].rpm < 1400)
						G4 S3 ; check again in 3 seconds in case it's just spinning up
							if (fans[1].rpm > 500) && (fans[1].rpm < 1400)
							echo "WARNING: Water pump RPM low - RPM : " ^ fans[1].rpm
							if (state.status=="processing")
								M25 ; pause print so you might be able to save it using M119
								;M41 P5 S1  ; activate output connected to externally powered latching relay here to sound alarm
								M0 ; unconditional stop.  If axes are homed and a print is being canceled will run cancel.g  otherwise will run stop.g
								M81 S1 ; turn off power when fans have turned off
					else
						;echo "Coolant OK - RPM : "  ^ fans[1].rpm

					if fans[2].rpm <=1000
						echo "WARNING: Water pump FAN RPM low - RPM : " ^ fans[2].rpm
						if (state.status=="processing")
							M25 ; pause print so you might be able to save it using M119
							;M41 P5 S1  ; activate output connected to externally powered latching relay here to sound alarm
							M0 ; unconditional stop.  If axes are homed and a print is being canceled will run cancel.g  otherwise will run stop.g
							M81 S1 ; turn off power when fans have turned off
					else
						;echo "water pump fan OK"

				if iterations == #heat.heaters-1 ; all heaters have been checked
					set global.LastCheckTime=state.upTime ; set the new time to check
					;echo "new check time = " ^ global.LastCheckTime
	; END HEATER CHECKS				
					
	; BEGIN OTHER CHECKS AT INTERVALS LESS THAN 10 SECONDS
	;echo state.upTime ^ ":" ^ state.msUpTime ; should run very fast
	;G4 P500
	;echo "fast checks outside every 2 seconds"
	; This should only trigger if a print is in progress and the runout value has been set by a runout.
	if (state.currentTool != -1) && (state.currentTool < #tools)
		if (move.extruders[tools[state.currentTool].filamentExtruder].position > global.filamentDistance)  &&  (global.filamentDistance !=0) && (state.status = "processing")
			echo "paused called from daemon - filament runout"	
			M25 ; pause print if filament has run out
		; Check if a deferred power down is in progress.
	if (state.deferredPowerDown==true) && (state.atxPower==true)
		M291 S0 R"Powering down" P"A deferred power down is in progress.  Send M80 to cancel" T3
		G4 S10
	; check if wifi is connected
	if (network.interfaces[0].actualIP="0.0.0.0") || (network.interfaces[0].actualIP=null)
		if exists(global.NetworkRestartTime)
			if global.NetworkRestartTime > state.time
				if fileexists("0:/sys/print_log.txt")
					echo >>"0:/sys/print_log.txt" "WiFi disconnected:  Restart attempted at : " ^ state.time
				M929 P"0:/sys/print_log.txt" S3
				M122
				M552 S-1 ; disable wifi
				G4 S2
				M552 S1 ; enable wifi
				M929 S0; stop logging
				set global.NetworkRestartTime = state.time + 60
		else
			global NetworkRestartTime = state.time + 60 ; set network restart time for 60 seconds from now
			if fileexists("0:/sys/print_log.txt")
				echo >>"0:/sys/print_log.txt" "WiFi disconnected:  WiFi module restart schedued for " ^ global.NetworkRestartTime
	; add a delay for the checks in this section
	G4 S2 ; add a delay for these checks		
		