; Unload filament
echo "begin do moves to unload.g"
M291 R"Unloading" P"Running do_moves_for_unload" S0 T2
M400 ; wait for any moves
if (state.currentTool=-1) || ({heat.heaters[tools[state.currentTool].heaters[0]].current < heat.coldRetractTemperature-3})
	M291 R"Can't proceed" P"No tool active or temp to low for extraction" S2 T10
	abort;
M83 ; set relative extrusion
echo "retracting"
M291 R"Retracting" P"Retracting filament.... Please wait" S1 T30
G1 E-100 F600 ; retract 100mm to clear hotend
M400 ; wait for moves to finish
echo "retract finished"
M291 R"Ready to change" P"Filament extracted.  Change roll" S0 T5
G10 S0 R0 ; turn off heater
G4 S5