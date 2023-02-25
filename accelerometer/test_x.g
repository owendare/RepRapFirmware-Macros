; 0:/macros/accelerometer/test_x.g
; Run accelerometer test. S parameter passed in M98 call determines orientation
; Edit variable to suit your printer
var StartX=50
var StartY = 90
var FinishX = 135
var Speed = 6000
var NumSamples = 1000

while iterations < #move.axes
	echo "Check if " ^ move.axes[iterations].letter ^ " homed.."
	if !move.axes[iterations].homed
		echo move.axes[iterations].letter ^ " axis not homed...   Homing all"
		G28
		break
;M593 P"none"     ; disable DAA
;echo "testing using " ^ {param.R}
if exists(param.R) && exists(param.F)
   M593 P{param.R} F{param.F} ;apply input shaping based on parameters passed.

echo "Moving to start position"
G1 X{var.StartX} Y{var.StartY} Z20 F3600
echo "In position"
M98 P"0:/macros/accelerometer/increase_max_speeds.g"
G4 S2
if exists(param.S)
	echo "testing only " ^ param.S ^ " axis of accelerometer"
	G4 P500
	if param.S="X"
		G1 X{var.FinishX} F{var.Speed}
		M400
		M956 P0 X S{var.NumSamples} A0
	elif param.S="Y"
		G1 X{var.FinishX} F{var.Speed}
		M400
		M956 P0 Y S{var.NumSamples} A0
	elif param.S="Z"
		G1 X{var.FinishX} F{var.Speed}
		M400
		M956 P0 Z S{var.NumSamples} A0
	else
		G1 X{var.FinishX} F{var.Speed}
		M400
		M956 P0 S{var.NumSamples} A0
else
	echo "Testing all axes"
	G1 X{var.FinishX} F{var.Speed}
	M400
	M956 P0 S{var.NumSamples} A0

echo "Test complete"
M98 P"0:/sys/set_max_speeds.g"