;; Universal unload.g  - direct all other filament unoad.g instances to this file
;;
echo "entering 0:/macros/filament/universal_unload.g"
if state.currentTool==-1
	M291 R"Error" P"No tool selected.  Unload aborted" S2
	M99
echo "waiting for unload temp"
if move.extruders[state.currentTool].filament == ""
	M291 R"Error" P"No filament loaded.  Unload aborted" S2 T2
	M99
M703 ; ensure correct filament settings are loaded.
var TargetTemp = heat.coldRetractTemperature + 5
M291 R{"Unloading " ^ move.extruders[state.currentTool].filament} P"Waiting for nozzle unloading temperature..." S0 T10
G4 S2
M568 P{state.currentTool} S{heat.coldExtrudeTemperature} R{var.TargetTemp} A1 ; Heat current tool just enough to cold pull
G4 S1
M292 ; close popup


;show progress of heating from lower temp
while (heat.heaters[tools[state.currentTool].heaters[state.currentTool]].current) < (var.TargetTemp - 2)
	M291 R"Preheating..  Please wait" P{"Current temp = " ^  heat.heaters[tools[state.currentTool].heaters[state.currentTool]].current ^ " : target = " ^ var.TargetTemp}  S0 T2
	G4 S1.8
	if global.Cancelled = true
		M98 P"0:/macros/heating/all_heaters_off.g"
		abort "heating cancelled"

;show progress of cooling from hotter temp
while  (heat.heaters[tools[state.currentTool].heaters[state.currentTool]].current) > (var.TargetTemp + 2)
	M291 R"Preheating..  Please wait" P{"Current temp = " ^  heat.heaters[tools[state.currentTool].heaters[state.currentTool]].current ^ " : target = " ^ var.TargetTemp}  S0 T2
	G4 S1.8
	if global.Cancelled = true
		M98 P"0:/macros/heating/all_heaters_off.g"
		abort "heating cancelled"

M116 S0.5                       ; Wait for temperature to be within 0.5 degrees of target

echo "waiting for filament to settle"
M291 R{"Unloading " ^ move.extruders[state.currentTool].filament} P"Waiting for filament to soften (or firm)..." S0 T10
G4 T10; Wait for additional delay for filament to cool or soften

echo "unloading"
M291 R{"Unloading " ^ move.extruders[state.currentTool].filament} P"Retracting..." S0 T5
M98 P"0:/macros/filament/do_moves_for_unload.g"
G92 E0 ; set extruder position to zero
echo "unloading complete"