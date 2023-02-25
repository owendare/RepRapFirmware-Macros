M291 R"Position" P"Position tool near bed?" S4 K{"Yes","No"} F1
if input = 0
	if move.axes[0].homed != true || move.axes[1].homed != true || move.axes[2].homed != true
		G28
	G1 X{global.Bed_Center_X} Y{global.Bed_Center_Y} Z5
M291 S5 H{#tools-1} L0 P"Select tool to tune" R"Tool" F0
var thisTool = input
var thisHeater = tools[var.thisTool].heaters[0]
var minTemp = heat.coldExtrudeTemperature + 5
var maxAmbient = 35
var chamberTemp = sensors.analog[2].lastReading
var sensorName = sensors.analog[2].name
var maxTemp = heat.heaters[var.thisHeater].max
M291 P"Set tuning temp" R"Temp" S6 H{var.maxTemp} L{var.minTemp} F220
var tuningTemp = input
if heat.heaters[var.thisHeater].current > var.maxAmbient
	M291 P"Heater is already hot.  Set current ambient temp" R{"Ambient:",var.sensorName,"temp = ",var.chamberTemp} S6 H{var.chamberTemp + 20} L{var.chamberTemp-10}  F{var.chamberTemp}
	var currentAmbient = input
	M303 T{var.thisTool} P1 S{var.tuningTemp} F1 Q1 A{var.currentAmbient}
else
	M303 T{var.thisTool} P1 S{var.tuningTemp} F1 Q1

while heat.heaters[1].state = "tuning"
	if state.messageBox = null
		M291 R"Tuning" P"Tuning in progress. Send ""M303 H-1"" to cancel" S0
if state.messageBox != null
	M292 P0
M291 R"Finished tuning" P"OK to save results, cancel to discard" S3
M500
M501