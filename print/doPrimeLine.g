; doPrimeLine.g
; example of calling from Prusa Slicer
;M98 P"0:/macros/print/doPrimeLine.g" S{extrusion_multiplier[current_extruder]} D{nozzle_diameter[current_extruder]} F{filament_diameter[current_extruder]} O{"{0,10}"} L150; 

if state.currentTool = -1
	abort "No tool selected"
var ThisHeater = tools[state.currentTool].heaters[0]
if {heat.heaters[var.ThisHeater].state != "active"}
	abort "Heater " ^ var.ThisHeater ^ " on " ^ tools[state.currentTool].name ^ " not active"
if  {heat.heaters[var.ThisHeater].active < heat.coldExtrudeTemperature}
	abort "Heater " ^ var.ThisHeater ^ " on " ^ tools[state.currentTool].name ^ " set below min extrude temp"
if !exists(param.S)
	abort "no ""S"" (extrusion factor) parameter sent to macro in M98"
if !exists(param.D)
	abort "no ""D"" (nozzle diameter) parameter sent to macro in M98"
if !exists(param.F)
	abort "no ""F"" (filament diameter) parameter sent to macro in M98"
if !exists(param.O)
	echo "no ""O"" (Origin) parameter sent to macro in M98.  Defaults will be used"
if !exists(param.L)
	echo "no ""L"" (Length) parameter sent to macro in M98.  Defaults will be used"

echo "wait for heaters"
M116 ; wait for heaters to settle
echo "heaters done"
G4 P500
echo "set height"
var height = 0.2 ; create a variable then set it depending on slicer commanded position prior to calling this macro
if move.axes[2].machinePosition <= 0.4
	set var.height = move.axes[2].machinePosition
else
	set var.height = 0.3
echo "move to Z" ^ var.height
M400
echo "check extrusion percentage"
var SF = 100
if param.S <=1 ; check if slicer sends percentage of 1 or 100
	set var.SF = param.S   ; extrusion multiplier as a percentage of 1
else
	set var.SF = param.S / 100
echo "check filament dianeter"
var FD = 1.75 ; set filament diameter
set var.FD = param.F
echo "calculate distance and extrusion amount"

var startPos = {0,move.axes[1].min + 10} ; create a default start point
if exists(param.O)
	set var.startPos = param.O
var start = var.startPos[1]
var end = {move.axes[1].max - 10} ; extrude line end default position
var l = var.end -  var.start ; default line length
if exists(param.L)
	set var.l = param.L
	set var.end = var.start + var.l
	; do a sanity check to ensure we're within bounds
	if var.end > move.axes[1].max
		set var.end = move.axes[1].max
		set var.l = var.end - var.start
var d = param.D*1.00 ; nozzle diameter that is passed to macro as paramater
var amount = ((var.d*var.height*var.l) + (pi*pow(var.height/2,2)*var.l)) / (pi*pow(var.FD/2,2)) * var.SF ; calculate how many mm of filament to extrude - Owen's calculation
echo "flow rate value " ^ var.SF ^ " with " ^ var.d ^ "mm nozzle, " ^  var.FD ^ "mm filament dia over " ^ var.l ^ "mm length = E" ^ var.amount ^ "mm"
M83 ; set relative extrusion
G92 E0
echo "moving to X" ^ var.startPos[0] ^ " Y" ^ var.startPos[1] ^ " Z" ^ var.height
G1 X{var.startPos[0]} Y{var.startPos[1]} Z{var.height} F1200 ; move to edge to wipe any oozed filament
M400
G92 E0
echo "Move and extrude to Y"^var.end ^ " E" ^ var.amount
G1 X{var.startPos[0]} Y{var.end} E{var.amount} F600; move and extrude
M400
G92 E0
echo "move over one nozzle width"
G1 X{var.d} ; move by one nozle width
M400
G92 E0
echo "Move and extrude - other direction"
G1  Y{var.start}  F600 E{var.amount}; move and extrude
M400
G92 E0
echo "retract"
;G10 ; retract
M400
G92 E0
echo "exit PrimLine"
G4 P500