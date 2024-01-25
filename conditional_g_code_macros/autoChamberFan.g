; 0:/sys daemon.g - by default will run once every 10 seconds
; ******************************************************************************
if !exists(global.autoChamberFan)
	global autoChamberFan = true ; create a global so we can opt out and manually control fan if needed
var heaterNumber = 1 ; set to whichever heater you're monitoring or hard code it belo
var fanNumber = 0 ; set to whatever fan you'recontrolling or hard code it below
var fanOffDelay = 60 ; delay to turn off the fan in seconds

if !exists(global.fanTimeOut)
	global fanTimeOut = (state.time  - 1) ; create our variable and set the initial value so the fan is off
if heat.heaters[var.heaterNumber].state != "off" ; heater is on, standby or tunin
	M106 P{var.fanNumber} S255  ; turn the fan on
	set global.fanTimeOut = state.time + var.fanOffDelay ; reset our timeout value
else  
	if global.fanTimeOut < state.time ; the fan is off, so we check if we've reashed teh timeout
		M106 P{var.fanNumber} S0 ; turn off the fan
; **********************************************************************************


; ************************************************************************************		
; use this code to run code every X seconds
; 0:/sys daemon.g - using a loop to run at less than 10 second intervals
;if !exists(global.autoChamberFan)
;	global autoChamberFan = true ; create a global so we can opt out and manually control fan if needed
;var loopTime = 2 ; set to number of seconds between checks
;var heaterNumber = 1 ; set to whichever heater you're monitoring or hard code it below
;var fanNumber = 0 ; set to whatever fan you'recontrolling or hard code it below
;var fanOffDelay = 60; delay to turn off the fan in seconds
;
;
;if !exists(global.fanTimeOut)
;	global fanTimeOut = state.time  - 1 ; create our variable and set the initial value so the fan is off.  Using a global so you can see it in object model
;	echo "initial timeout = " , global.fanTimeOut
;while true
;	if (heat.heaters[var.heaterNumber].state != "off") && (global.autoChamberFan = true) ; heater is on, standby or tuning
;		set global.fanTimeOut = state.time + var.fanOffDelay ; reset our timeout value
;		echo "time = " ^ state.time ^ "  :  New timeout = " ^ global.fanTimeOut  
;		M106 P{var.fanNumber} S255  ; turn the fan on
;	else  
;		if (global.fanTimeOut < state.time) && (global.autoChamberFan = true) ; the fan is off, so we check if we've reashed the timeout		
;			M106 P{var.fanNumber} S0 ; turn off the fan
;	G4 S{var.loopTime}
; *****************************************************************************************