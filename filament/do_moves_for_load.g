;do moves for load.g - run when filament change is done.
; can accept the following parameters
; F = The extrusion speed to use.  If not passed, global variable value is used.  set default in config.g and adjust per filament in filaments/X/config.g
; S = the amount to extrude.
;echo "entering do_moves_for_load.g"
var extrudeAmount = 50 ; default - how many mm of filament to extrude with each iteration.  
var extrudeSpeed = 120 ; default - extrusion speed to use

if exists(param.S) ; check is a custom was passed
	set var.extrudeAmount = param.S
if exists(param.F)
	set var.extrudeSpeed = param.F
else
	set var.extrudeSpeed = global.filamentFeedSpeed ; fall back to the global variable

M400 ; wait for any moves
if state.currentTool=-1
    M291 P"No tool active" R"Can't proceed" S0 T10
    abort "no active tool";
	
; double check we have the temp set and the heater is active.
if ((heat.heaters[tools[state.currentTool].heaters[0]].active) < (heat.coldExtrudeTemperature+10)) || (heat.heaters[tools[state.currentTool].heaters[0]].state!="active")
	M568 P{state.currentTool} R{heat.coldRetractTemperature} S{heat.coldExtrudeTemperature+10} A2 ; set nozzle temp , standby and make active
echo "Waiting for temperature"
M116 ; wait for any heating commands

; make sure we haven't dipped under the cold extrude temp while the temp is settling
var thisHeater = tools[state.currentTool].heaters[0]
while {(heat.heaters[var.thisHeater].current) < (heat.coldExtrudeTemperature)}
	echo "Temp is under cold extrude value.  Waiting to settle"
	G4 S6
	if iterations = 10
		echo "Temp taking too long to reach cold extrude"
		break

	
if  {(heat.heaters[var.thisHeater].current) < (heat.coldExtrudeTemperature)}
	M291 P{"Temp (" ^ heat.heaters[var.thisHeater].current ^ ") below cold extrude value"} R"Can't proceed" S0 T3
	;M929 S0 ; stop logging
	abort "Temp below cold extrude value - aborting";

M83 ; set relative extrusion
while true
	if iterations = 5
		echo "Maximum number of feed attempts exceeded"
		break
	;if state.messageBox != null
	;	M292 P0
	M291 P{"Press OK to feed " ^ var.extrudeAmount ^ " of filament or CANCEL to abort"} R"Ready"  S3
	var extruded = 0
	while var.extruded  < var.extrudeAmount
		G1 E1 F180
		M291 P{"Please wait " ^ var.extruded + 1 ^ "mm of " ^ var.extrudeAmount ^ "mm fed"} R"Feeding filament"  S0
		M400
		set var.extruded = var.extruded + 1
	G10 ; Retract to reduce pressure
	M400 ; wait for moves to finish

echo "finished do moves to load.g"
M291 R"Done" P{move.extruders[state.currentTool].filament} ^  " Filament loaded.  Clear nozzle to proceed" S3