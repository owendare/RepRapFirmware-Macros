set global.Cancelled = false
if state.currentTool=-1
	M291 R"No active tool" P"No active tool.  OK to select T0, CANCEL to abort" S3
	T0
if (move.extruders[state.currentTool].filament == "") && (global.LoadedFilament="No_Filament") ;no filament loaded and none set in variable
	M302 S210 R120 ; modify these temps as required to suit most filaments used
	set global.BedPreheatTemp=60 ; set the default bed temp
	M291 R"No filament" P"No filament loaded.  Setting default temps" S0 T3
	G4 S3	
	M291 R"Preheating" P{"Setting preheat temperatures for " ^ global.LoadedFilament} S0 T3

else
	M98 P{"0:\filaments\" ^ global.LoadedFilament ^ "\config.g"} ; load config to get extrude temps etc

var TargetTemp = heat.coldExtrudeTemperature+5
; set tool temps
M140 S{global.BedPreheatTemp} R{floor(global.BedPreheatTemp*0.75)}
M568 P{state.currentTool} R{heat.coldRetractTemperature} S{var.TargetTemp} A2 ; set nozzle temp , standby and make active
G4 S3

;show progress of heating from lower temp
while (heat.heaters[tools[state.currentTool].heaters[state.currentTool]].current) < (var.TargetTemp - 2)
	M291 R"Preheating..  Please wait" P{"Current temp = " ^  heat.heaters[tools[state.currentTool].heaters[state.currentTool]].current ^ " : target = " ^ (var.TargetTemp) }  S0 T2
	G4 S1.8
	if global.Cancelled = true
		M98 P"0:/macros/heating/all_heaters_off.g"
		abort "heating cancelled"

;show progress of cooling from hotter temp
while  (heat.heaters[tools[state.currentTool].heaters[state.currentTool]].current) > (var.TargetTemp + 2)
	M291 R"Preheating..  Please wait" P{"Current temp = " ^  heat.heaters[tools[state.currentTool].heaters[state.currentTool]].current ^ " : target = " ^ (var.TargetTemp)}  S0 T2
	G4 S1.8
	if global.Cancelled = true
		M98 P"0:/macros/heating/all_heaters_off.g"
		abort "heating cancelled"
	
;show progress of bed
while  (heat.heaters[0].current > global.BedPreheatTemp + 3) || (heat.heaters[0].current < global.BedPreheatTemp - 3)
	M291 R"Waiting for bed..." P{"Current temp = " ^  heat.heaters[0].current ^ " : target = " ^ (global.BedPreheatTemp)}  S0 T2
	G4 S1.8
	if global.Cancelled = true
		M98 P"0:/macros/heating/all_heaters_off.g"
		abort "heating cancelled"
M116 ; wait for temps to settle
M291 R"Preheating" P"Preheating... Done" S0 T2