;; Universal unload.g  - direct all other filament unoad.g instances to this file
;;
;M929 P"0:/macros/filament/unloadeventlog.txt" S3
echo "entering 0:/macros/filament/universal_unload.g"
M106 S0  ; fan off
;move to a good height and centre of bed
while iterations < #move.axes
	if !move.axes[iterations].homed
		echo "Homing"
		G28 
M400

if (move.axes[0].userPosition!=global.Bed_Center_X) || (move.axes[1].userPosition!=global.Bed_Center_Y) || (move.axes[2].userPosition!=75)
	M291 R"Positioning" P"Moving to safe extrude height" S1 T2
	G1 X{global.Bed_Center_X} Y{global.Bed_Center_Y} Z75 F3600
M400

if state.currentTool==-1
	M291 R"No Tool" P"No tool selected.  OK to unload tool 0, Cancel to abort" S2
	T0 P0
echo "waiting for unload temp"

if (move.extruders[state.currentTool].filament == "") || (global.LoadedFilament="") || (global.LoadedFilament==null)
	M291 R"Error" P"No filament loaded.  Unload aborted" S2 T2
	M99
	
var TargetTemp = heat.coldRetractTemperature + 5
;M291 R{"Unloading " ^ move.extruders[state.currentTool].filament} P"Waiting for nozzle unloading temperature..." S0 T3
M568 P{state.currentTool} S{heat.coldExtrudeTemperature+10} R{var.TargetTemp} A1 ; Heat current tool just enough to cold pull
G4 S3
var thisHeater = tools[state.currentTool].heaters[0]
;show progress of heating from lower temp
while (heat.heaters[tools[state.currentTool].heaters[0]].current) < (var.TargetTemp - 1)
	M291 R"Preheating..  Please wait" P{"Current temp = " ^  heat.heaters[var.thisHeater].current ^ " : target = " ^ var.TargetTemp}  S0 T2
	G4 S1.8
	if global.Cancelled = true
		M108
		M98 P"0:/macros/heating/all_heaters_off.g"
		abort "heating cancelled"

if  (heat.heaters[var.thisHeater].current) > (var.TargetTemp + 1)
	echo "Fan on to help cooling faster"
	M106 S1

;show progress of cooling from hotter temp
while  (heat.heaters[var.thisHeater].current) > (var.TargetTemp + 1)
	M291 R"Preheating..  Please wait" P{"Current temp = " ^  heat.heaters[var.thisHeater].current ^ " : target = " ^ var.TargetTemp}  S0 T2
	G4 S1.8
	if global.Cancelled = true
		M108
		M98 P"0:/macros/heating/all_heaters_off.g"
		abort "heating cancelled"

M106 S0 ; turn off part fan
M116                       ; Wait for temperature to be within 0.5 degrees of target

echo "waiting for filament to settle"
;M291 R{"Unloading " ^ move.extruders[state.currentTool].filament} P"Waiting for filament to soften (or firm)..." S0 T10
G4 T10; Wait for additional delay for filament to cool or soften

echo "unloading"
M291 R{"Unloading " ^ move.extruders[state.currentTool].filament} P"Retracting..." S0 T5
M98 P"0:/macros/filament/do_moves_for_unload.g"

M568 P{state.currentTool} S{heat.coldExtrudeTemperature+10} R{var.TargetTemp} A2 ; Heat current tool to cold extrude temp
echo "Heating to cold extrude temp..  Please wait"
M116
echo "unloading complete - exiting universal_unload.g"
;M929 S0