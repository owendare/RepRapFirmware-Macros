;do moves for load.g - run when filament change is done.
M291 P"loading do_moves_for_load.g" S1 T4
M400 ; wait for any moves
M116 ; wait for any heating commands
if state.currentTool=-1
    M291 P"No tool active" R"Can't proceed" S3 T10
    abort;
if  {(heat.heaters[tools[state.currentTool].heaters[state.currentTool]].current) < (heat.coldExtrudeTemperature)}
	M291 P"Temp below cold extrude value" R"Can't proceed" S3 T10
	abort;

M83 ; set relative extrusion
while true
	if iterations = 5
		break
	M291 P"Press OK to feed 120mm of filament or CANCEL to abort" R"Ready"  S3
	while iterations  < 120
		G1 E1 F180
		M291 P{"Please wait " ^ iterations ^ "mm of 120mm fed"} R"Feeding filament"  S0
		M400
	G1 E-2 ; Retract 2mm to reduce pressure
	M400 ; wait for moves to finish


M400 ; wait for moves to finish
echo "finished do moves to load.g"
M291 R"Done" P{move.extruders[state.currentTool].filament} ^  " Filament loaded.  Clear nozzle to proceed" S3