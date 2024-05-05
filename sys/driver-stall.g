;0:/sys/driver-stall.g

var allowedSteps = 3 ; adjust as required.  Number of measured steps to constitute a valid error
var macroLocation = "0:/macros/homing/dist2home.g" ; adjust as required

var filePos = job.filePosition
M400 ; wait for moves in queue to stop
G60 S5 ; save position to slot 5
M25 ; pause
G1 R5 X0 Y0 Z0 F3600;
M400

var Axis = "" ; start with no value
var subLoop = 0
var mainLoop = 0
echo "stall on driver " ^ param.D
while var.mainLoop < #move.axes
	set var.subLoop = 0
	while var.subLoop < #move.axes[var.mainLoop].drivers		
	if (param.D ^ "") = (move.axes[var.mainLoop].drivers[var.subLoop] ^ "")
		set var.Axis = move.axes[var.mainLoop].letter
		set var.subLoop = var.subLoop + 1
	set var.mainLoop = var.mainLoop + 1
if var.Axis = ""
	echo "No axis letter found for driver " ^ param.D
	M99
else
	echo "Error is on " ^ var.Axis ^ " axis"
	if (var.Axis="X") || (var.Axis="Y")
		M98 P{var.macroLocation} A{var.Axis} S{var.allowedSteps} R{var.filePos} D{param.D}; only run the file if it's X or Y axis fault
M24 ; resume print
	