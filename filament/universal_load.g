;; universal_load.g  All filament load.g files call this one.
echo "entering 0:/macros/filament/universal_load.g" 
; filament to load is stored in global variable - global.LoadedFilament
M291 R{"Loading " ^ global.LoadedFilament} P"Loading config and heating" S1 T3
G4 S3
echo "attempting to load config for " ^ global.LoadedFilament

M98 P{"0:\filaments\" ^ global.LoadedFilament ^ "\config.g"} ; load config to get extrude temps etc


if result==0
	echo "config loaded"
else
	echo "error loading config"

echo "check tool"

;check if no tool selected or if heater is off
if state.currentTool=-1
	T0 P0
if heat.heaters[state.currentTool].state="off"
	T0 P0
	M568 P{state.currentTool} R0 S0 A0

echo "waiting for temp"

M291 R{"Loading " ^ global.LoadedFilament} P"Waiting for nozzle loading temperature..." S1 T0
M98 P"0:/macros/heating/preheat_current_filament.g" ; preheat to the temps set in filament config.g
M116                            ; Wait for temperature

;check if the requested filament is already loaded
if move.extruders[state.currentTool].filament=global.LoadedFilament
	echo "filament already loaded"
	M291 R"Cancel loading" P"Filament already loaded.  Skipping load moves" S3
	G4 S3
	M99;


; opt out option as print in running
if job.file.fileName!=null && state.status!="paused"
	echo "Print job is running - confirmation required"
	M291 R"Confirm?" P"A print job is in progress.  Press OK to continue or CANCEL to abort" S3

;we know the requested filament isn't loaded, but if something else is, we need to unload it first
if move.extruders[state.currentTool].filament!=""
	echo "unload required"
	if move.extruders[state.currentTool].filament!=global.LoadedFilament
		M702 S{"{move.extruders[state.currentTool].filament}"}
		M291 R"Unload finished" P"Press OK when ready to load new filament" S3
		echo "another filament loaded, so load new one"
		M701 S{global.LoadedFilament}

; we check filament loaded again in case this is a second loop from an unload.
if move.extruders[state.currentTool].filament!=global.LoadedFilament
	echo "loading filament"
	M291 R{"Loading " ^ global.LoadedFilament} P"Feeding and priming..." S0 T3
	M98 P"0:/macros/filament/do_moves_for_load.g"
	echo "loading complete"
G92 E0 ; set extruder position to zero
M291 R{"Loading " ^ global.LoadedFilament} P"Filament loaded....." S1 T5
M98 P"0:/macros/songs/simpsons.g"
echo "exiting universal_load.g"
G4 S3
