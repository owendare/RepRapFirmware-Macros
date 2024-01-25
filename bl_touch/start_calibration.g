; start_calibration.g
; should be located in same folder as calibrate_BLtouch.g
; Reprap firmware version 3.5rc1 or later required!
; If macro is called using parameters these will be used in testing
; If any parameters are omitted, the default values will be used.
; parameters which can be passed are
; T - Tool to use
; B - bed temperature to use
; R - Nozzle temperature to use (may be turned off before probing commences if configuerd to do so in config.g)
; P - probe number to use
; F -  X/Y travel speed to use (in mm/sec)
var F = 80
; Z - Z travel speed to use
var Z = 6
; S - Probe speed to use (in mm/sec)
var S = 1
; I - Number of times to probe (high and low value will be discarded)
; the following variables are re-set at run time
var R = 0
var B = 0
var T = -1
var P = 0
var maxBedTemp = floor(heat.heaters[heat.bedHeaters[0]].max) 
var I = 10 ; default number of probes (two extra will be done and high/low discarded)
var choice = 0 ; do not change
var systemVoltage = 24  ; change to suit voltage of your system!

; check firmware version
if datetime(boards[0].firmwareDate ^ "T0:00:00") < datetime("2023-09-01T0:00:00")
	abort "Firmware version 3.5 or later required"

M291 S5 R"Tool" P"Select Tool Number" L0 H{#tools-1} F0 J1
set var.T = input
var Heater = tools[var.T].heaters[0]
var maxTemp = floor(heat.heaters[var.Heater].max)
echo "maxTemp="^var.maxTemp
var minTemp = floor(heat.coldExtrudeTemperature + 5)
echo "minTemp="^var.minTemp
M291 S4 R"Heat" P"Heat tool/bed ?" K{"None","Nozzle only","Bed only","Both",} F0 J1
set var.choice = input
if var.choice!=0
	;echo "Heat choice " ^ var.choice
	if (var.choice = 1) || (var.choice = 3)
		;echo var.minTemp
		;echo var.maxTemp
		M291 S6 R"Nozzle temp" P"Set temperature for nozzle" L{var.minTemp} H{var.maxTemp} F{var.minTemp} J1
		set var.R = floor(input)
	if (var.choice = 2) || (var.choice = 3)
		M291 S6 R"Bed temp" P"Set temperature for bed" L0 H{var.maxBedTemp} F40 J1
		set var.B = floor(input)
if #sensors.probes > 1
	M291 S5 R"Probe" P"Select probe" L0 H{#sensors.probes-1} F0 J1
	set var.P = input
M291 S5 R"Cycles" P"Enter number of cycles to sample" L3 H22 F{var.I} J1
set var.I = input + 2
;echo "M98 P0:/macros/bl_touch/calibrate_BLtouch.g B"^{var.B}^" T"^{var.T}^" R"^{var.R}^" P"^{var.P}^" F"^{var.F}^" Z"^{var.Z}^" S"^{var.S}^" I"^{var.I}

if state.atxPowerPort != null
	if state.atxPower = false
		M80
		while boards[0].vIn.current < var.systemVoltage
			echo "waiting for power up -- VIN=" ^ boards[0].vIn.current
			G4 S1
G4 S1
; If the printer hasn't been homed, home it
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
	echo "Homing - please wait"
	G28
	M400

; run the file to do the calibration
if fileexists("0:/macros/bl_touch/calibrate_BLtouch.g")
	M98 P"0:/macros/bl_touch/calibrate_BLtouch.g" B{var.B} T{var.T} R{var.R} P{var.P} F{var.F} Z{var.Z} S{var.S} I{var.I}
elif fileexists("0:/macros/calibrate_BLtouch.g")
	M98 P"0:/macros/calibrate_BLtouch.g" B{var.B} T{var.T} R{var.R} P{var.P} F{var.F} Z{var.Z} S{var.S} I{var.I}
elif fileexists("calibrate_BLtouch.g")
	M98 P"calibrate_BLtouch.g" B{var.B} T{var.T} R{var.R} P{var.P} F{var.F} Z{var.Z} S{var.S} I{var.I}
else
	echo "File not found : calibrate_BLtouch.g" 
	echo "Recommended location is 0:/macros/bl_touch/"