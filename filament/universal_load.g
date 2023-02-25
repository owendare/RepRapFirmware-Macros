;; universal_load.g  All filament load.g files call this one.
;M929 P"0:/macros/filament/loadeventlog.txt" S3 ; start logging
echo "entering 0:/macros/filament/universal_load.g" 

;check if homed and move to a good height and centre of bed
while iterations < #move.axes
	if !move.axes[iterations].homed
		G28
M400		
; check if we are at the defined best load/unload position
if (move.axes[0].userPosition!=global.Bed_Center_X) || (move.axes[1].userPosition!=global.Bed_Center_Y) || (move.axes[2].userPosition!=75)
	M291 R"Positioning" P"Moving to safe extrude height" S2 T2
	G1 X{global.Bed_Center_X} Y{global.Bed_Center_Y} Z75 F3600
M400
;check if no tool selected or if heater is off
if state.currentTool=-1
	echo "No tool selected.  Setting tool 0 active"
	T0 P0
; filament to load is stored in global variable - global.LoadedFilament
M80 ; ensure machine is powered up
G4 S3
M42 P5 S1 ; make sure the LED lights are on so we can see to load the filament
;M291 R{"Loading " ^ global.LoadedFilament} P"Loading config and heating" S1 T3
G4 S3
echo "attempting to load config for " ^ global.LoadedFilament

M98 P{"0:\filaments\" ^ global.LoadedFilament ^ "\config.g"} ; load config to get cold extrude temps etc
if result=0
	echo "config loaded successfully"
else
	echo "error loading config"

echo "pre heating"
M98 P"0:/macros/heating/preheat_current_filament.g" F1 ; preheat to the temps set in filament config.g
if result !=0
	echo "Error setting temp"
M291 R{"Loading " ^ global.LoadedFilament} P"Waiting for nozzle loading temperature..." S0 T3
M116; Wait for temperature
echo "waiting for temp to stabilize"
G4 S15 ; wait to stabilise

;check if the requested filament is already loaded and a filament runout hasn't occured
if (move.extruders[state.currentTool].filament=global.LoadedFilament) && (global.filamentDistance=0)
	echo "filament shows as already loaded.  confirm loading required?"
	M291 R"Continue loading?" P{global.LoadedFilament ^ " filament already loaded.  OK to do load moves"} S3

; opt out option as print in running
if job.file.fileName!=null && state.status!="paused"
	echo "Print job is running - confirmation required"
	M291 R"Confirm?" P"A print job is in progress.  Press OK to continue or CANCEL to abort" S3


;we know the requested filament isn't loaded, but if something else is, we need to unload it first
if {move.extruders[state.currentTool].filament!=""} && {global.filamentDistance=0}
	echo "unload required"
	if move.extruders[state.currentTool].filament!=global.LoadedFilament
		M702 S{"{move.extruders[state.currentTool].filament}"}
		M291 R"Unload finished" P"Press OK when ready to load new filament" S3
		echo "another filament loaded, so load new one"
		M701 S{global.LoadedFilament}

; we check filament loaded again in case this is a second loop from an unload.
; also we check if the filament is loaded, but we're in the middle of a runout situation & reload
if state.currentTool=-1
	echo "No tool selected.  Setting tool 0 active"
	T0 P0
if {move.extruders[state.currentTool].filament!=global.LoadedFilament}
	echo "loading filament"
	M291 R{"Loading " ^ global.LoadedFilament} P"Feeding and priming..." S0 T3
	G4 S4
	M98 P"0:/macros/filament/do_moves_for_load.g"
	echo "loading complete"

M291 R{"Loading " ^ global.LoadedFilament} P"Filament loaded....." S0 T3
G4 S3
M98 P"0:/macros/songs/simpsons.g"
set global.filamentDistance = 0 ; reset filament sensor extrusion distance after tripping
echo "exiting universal_load.g"
M568 P{state.currentTool} A0 ; turn off heater again
;M929 S0 ; stop logging