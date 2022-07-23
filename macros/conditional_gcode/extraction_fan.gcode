; ******************  EXTRACTION FAN CONFIGURATION SECTION **********************
; configure your fan output.
; we assume here a gpio is used with an SSR to control a mains powered extraction/filter
; You could configure and use a fan output and change the code in daemon.g to use M106 instead of M42
;M950 P5 C"exp.e5_stop" 	; Output 5 uses E5_STOP  pin
M42 P5 S1 ; Start with the output turned on so extraction happens immediately on a restart

; create or reset a global variable that sets how long the fan runs after heating
if !exists(global.ExtractionTime)
	global ExtractionTime = 20 * 60  ; Time in seconds for fan to run after heating finished 
else
	set global.ExtractionTime = 20 * 60  ;

; create or reset  global variable to store the time we want the fan to shut down
if !exists(global.FanShutDownTime)
	global FanShutDownTime = state.time  ; this will be reset in daemon.g if needed
else
	set global.FanShutDownTime = state.time

;create or reset a global variable the records whether a heater is active or at melt temperature
if !exists(global.NeedFan)
	global NeedFan = false
else
	set global.NeedFan = false	
	
; ******************  END OF EXTRACTION FAN CONFIGURATION SECTION **********************


; THIS SECTION GOES INTO daemon.g
; ******************  EXTRACTION FAN REQUIREMENT CHECK **********************

; Check to see if the globals have been created yet in case daemon.g started before config.g finished
; If the last global created exists we run the code

echo "setting tool count"
; create a variable so we can loop through multiple tools with multiple heaters
if !exists(global.ToolCount)
	global ToolCount = 0
else 
	set global.ToolCount = 0 
echo "set tool count done"

if exists(global.NeedFan)
	set global.NeedFan = false ; first we set the fan requirement to false
	echo "start first loop"
	while global.ToolCount < #tools ; create a loop	to check all extruder heaters.   If the heater isn't off or it is over melt temp then we need the fan to run another X minutes
		echo " Tool loop " ^ global.ToolCount
		while iterations < #tools[global.ToolCount].heaters
			echo "heater loop" ^ iterations
			if (heat.heaters[tools[global.ToolCount].heaters[iterations]].state != "off")  || ((heat.heaters[tools[global.ToolCount].heaters[iterations]].current) >= (heat.coldRetractTemperature))
				echo "heater " ^ iterations ^ " matches pattern"
				set global.FanShutDownTime = statetime + global.ExtractionTime ; extend the shutdown time
				set global.NeedFan = true ; set the fan variable
				M42 P5 S1 ; Turn on the fan output.  Use M106 instead if using  fan output.
				set global.ToolCount = #tools ; this will break the first loop
				break ; no need to keep checking in the second loop as we've found a heater that needs extraction
		echo "incrementToolCount"
		set global.ToolCount = (global.ToolCount + 1) ; increment the counter for the tools we've checked
			
			; Now we can check if the fan needs to be turned off
	echo "time : " ^ state.time ^ " shut down due " ^ global.FanShutDownTime
	if state.time >= global.FanShutDownTime
		M42 P5 S0 ; turn off the fan because it's more than the required time since it was last needed.
		echo "fan turned off"
	else
		echo "fan left on"			
; ******************  END EXTRACTION FAN REQUIREMENT CHECK **********************	 