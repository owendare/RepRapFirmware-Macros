;0:/macros/tuning/PID_autotune_tool.g
; requires RRF 3.5b2+ or later
; Used to PID auto tune selected tools and associated tools
; if more than 1 tooland/or heater is defined, a choice is presented

; if we're not homed, offer to home axes
if move.axes[0].homed != true || move.axes[1].homed != true || move.axes[2].homed != true
	M291 R"Home" P"Home axes?" S4 K{"Yes","No"} F1
	G4 P100
	if result = 0
		if input = 0
			G28
			M400
			G4 S1
	else
		abort "Error displaying M291 panel for homing"

; if axes are all homed allow movement so nozzle (and fans) can be placed near bed if needed 
if move.axes[0].homed = true && move.axes[1].homed = true && move.axes[2].homed = true
	M291 S3 P"Move nozzle to required position & height (usually near bed)" X1 Y1 Z1
	M400
	G4 S1
var thisTool= 0 ; default tool to tune

var toolsArray = vector(#tools,0) ; if more than one tool, the a selection must be made
while iterations < #var.toolsArray
	if tools[iterations].name != null
		set var.toolsArray[iterations] = tools[iterations].name ^ "." ; need to add a period to return an array of strings.  Nt sure why??
	else
		set var.toolsArray[iterations] =  "Tool : " ^ tools[iterations] ;tools[iterations].number
;echo var.toolsArray

if #tools > 1
	M291 S4 K{var.toolsArray} P"Select tool to tune" R"Tool" F0
	G4 P100
	if result = 0
		set var.thisTool = input
	else
		abort "error displaying M291 panel for tool"

;echo "Tool", var.thisTool , "selected for tuning"

var heaterArray = vector(#tools[var.thisTool].heaters,0)
while iterations < #var.heaterArray
	set var.heaterArray[iterations]="Heater: " ^ tools[var.thisTool].heaters[iterations]

var thisHeater = tools[var.thisTool].heaters[0] ; default tool heater to tune
echo "tool to tune is " ^ var.thisTool
echo "heater to tune is " ^ var.thisHeater
if #var.heaterArray > 1  ; if there are multiple heaters then a choice must be made
	M291 S4 K{var.heaterArray} P{"Select which heater on tool " ^ var.thisTool ^ " to tune"} R"Heater" F0
	G4 P100
	if result = 0
		set var.thisHeater = input	
	else
		abort "error displaying M291 panel for heaters"	

; set variables for temperatures and ambient temp sensors
var minTemp = heat.coldExtrudeTemperature + 5
var maxAmbient = 35
var chamberTemp = sensors.analog[2].lastReading
var sensorName = sensors.analog[2].name
var maxTemp = heat.heaters[var.thisHeater].max
M291 P"Set tuning temp" R"Temp" S6 H{var.maxTemp} L{var.minTemp} F{heat.coldExtrudeTemperature + 20}
var tuningTemp = input

M291 S3 P"Ready to tune?" R"Confirm" ; last chance to bail out

if heat.heaters[var.thisHeater].current > var.maxAmbient
	M291 P"Heater is already hot.  Set current ambient temp" R{"Sensor " ^ var.sensorName ^ " reports Ambient temp = " ^ var.chamberTemp} S6 H{var.chamberTemp + 20} L{var.chamberTemp-10}  F{var.chamberTemp}
	var currentAmbient = input
	M303 T{var.thisTool} H{var.thisHeater} P1 S{var.tuningTemp} F1 Q1 A{var.currentAmbient}
	if result !=0
		abort "PID Tuning error"
else
	M303 T{var.thisTool} H{var.thisHeater} P1 S{var.tuningTemp} F1 Q1
	if result !=0
		abort "PID Tuning error"

while heat.heaters[1].state = "tuning"
	;if state.messageBox = null
	M291 R"Tuning" P"Tuning in progress. Send ""M303 H-1"" to cancel" S1 T2
	G4 S4
;if state.messageBox != null
;	M292 P0
M291 R"Finished tuning" P"OK to save results to config-override.g, cancel to discard" S3
M500
if fileexists(directories.system ^ "config-override.g")
	M291 R"Reload config?" P"OK to reload config-override.g values." S3
	M501