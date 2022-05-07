; Unload filament
;echo "begin do_moves_to_unload.g"
var RetractDistance = 120 ; must be a positive number high enough to withdraw filament completely from heat break!!
M291 R"Unloading" P"Running do_moves_for_unload" S0 T2
M400 ; wait for any moves
if (state.currentTool=-1) || ({heat.heaters[tools[state.currentTool].heaters[0]].current < heat.coldRetractTemperature-3})
	M291 R"Can't proceed" P"No tool active or temp to low for extraction" S2 T10
	abort;
M83 ; set relative extrusion
;echo "retracting"
M291 R"Retracting" P"Retracting filament.... Please wait" S1 T30
while iterations < var.RetractDistance-1
	G1 E-1 F{global.filamentRetractSpeed} ; retract 1mm at a time to clear hotend
	M291 S0 R"Retracting" P{"Retracted " ^ iterations + 1 ^ "mm of " ^ var.RetractDistance} T1
	M400
M400 ; wait for moves to finish
;echo "retract finished"
M291 R"Ready to change" P"Filament extracted.  Change roll" S0 T5
M568 A0 ; turn off heater
;echo "exiting do_moves_to_unload.g"