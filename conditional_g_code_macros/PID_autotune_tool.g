M291 S5 H{#tools-1} P"Select tool to tune" R"Tool" F0
var thisTool = input
var thisHeater = tools[var.thisTool].heaters[0]
var minTemp = heat.coldExtrudeTemperature + 5
var maxAmbient = 10
var maxTemp = heat.heaters[var.thisHeater].max
M291 P"Set tuning temp" R"Temp" S6 H{var.maxTemp} L{var.minTemp} F220
var tuningTemp = input
if heat.heaters[var.thisHeater].current > var.maxAmbient
	M291 P"Heater is already hot.  Set current ambient temp" R"Ambient" S6 H{var.maxAmbient + 20} L{var.maxAmbient} 
	var currentAmbient = input
	M303 T{var.thisTool} P1 S{var.tuningTemp} F1 Q1 A{var.currentAmbient}
else
	M303 T{var.thisTool} P1 S{var.tuningTemp} F1 Q1

while heat.heaters[1].state = "tuning"
	if state.messageBox = null
		M291 R"Tuning" P"Tuning in progress" S4 K{"OK","Cancel"} F1
	if {input = 1}
		;M303 H-1 ; cancel heating when introduced
		M99
M291 R"Finished tuning" P"OK to save results, cancel to discard" S3
M500