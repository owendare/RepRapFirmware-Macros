;; Universal unload.g  - direct all other filament unoad.g instances to this file
;;
;M929 P"0:/macros/filament/unloadeventlog.txt" S3
echo "entering 0:/macros/filament/universal_unload.g"

if state.currentTool==-1
	M291 R"No Tool" P"No tool selected.  OK to unload tool 0, Cancel to abort" S2
	T0 P0
echo "waiting for unload temp"

if (move.extruders[state.currentTool].filament == "") || (global.LoadedFilament="") || (global.LoadedFilament==null)
	M291 R"Error" P"No filament loaded.  Unload aborted" S2 T2
	M99

;M291 R{"Loading " ^ global.LoadedFilament} P"Loading config and heating" S1 T3
G4 S3
echo "attempting to load config for " ^ global.LoadedFilament

M98 P{"0:\filaments\" ^ global.LoadedFilament ^ "\config.g"} ; load config to get extrude temps etc
if result==0
	echo "config loaded"
else
	echo "error loading config"
	
var TargetTemp = heat.coldRetractTemperature + 5
;M291 R{"Unloading " ^ move.extruders[state.currentTool].filament} P"Waiting for nozzle unloading temperature..." S0 T3
M568 P{state.currentTool} S{heat.coldExtrudeTemperature+10} R{var.TargetTemp} A1 ; Heat current tool just enough to cold pull
G4 S3

;show progress of heating from lower temp
while (heat.heaters[tools[state.currentTool].heaters[state.currentTool]].current) < (var.TargetTemp - 1)
	M291 R"Preheating..  Please wait" P{"Current temp = " ^  heat.heaters[tools[state.currentTool].heaters[state.currentTool]].current ^ " : target = " ^ var.TargetTemp}  S0 T2
	G4 S1.8
	if global.Cancelled = true
		M98 P"0:/macros/heating/all_heaters_off.g"
		abort "heating cancelled"

;show progress of cooling from hotter temp
while  (heat.heaters[tools[state.currentTool].heaters[state.currentTool]].current) > (var.TargetTemp + 1)
	M291 R"Preheating..  Please wait" P{"Current temp = " ^  heat.heaters[tools[state.currentTool].heaters[state.currentTool]].current ^ " : target = " ^ var.TargetTemp}  S0 T2
	G4 S1.8
	if global.Cancelled = true
		M98 P"0:/macros/heating/all_heaters_off.g"
		abort "heating cancelled"

M116                       ; Wait for temperature to be within 0.5 degrees of target

echo "waiting for filament to settle"
;M291 R{"Unloading " ^ move.extruders[state.currentTool].filament} P"Waiting for filament to soften (or firm)..." S0 T10
G4 T10; Wait for additional delay for filament to cool or soften

echo "unloading"
M291 R{"Unloading " ^ move.extruders[state.currentTool].filament} P"Retracting..." S0 T5
M98 P"0:/macros/filament/do_moves_for_unload.g"

M568 P{state.currentTool} S{heat.coldExtrudeTemperature+10} R{var.TargetTemp} A2 ; Heat current tool to cold extrude temp
echo "Heating to cold extrude temp"
M116
echo "unloading complete - exiting universal_unload.g"
;M929 S0