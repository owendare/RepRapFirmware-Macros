;0:/sys/filament_error.g
;run when a filament sensor error is detected.  Print will be paused bt Daemon.g after runout distance.
var runoutDistance = 350 ; this is just so you can change easily 
; first check that we are not currently in an error state and the switch has been toggled again.
if (global.filamentDistance !=0) || (state.status != "processing")
	echo "Filament sensor triggered, but no print in progress.  No action taken"
	M99 ; exit macro
echo "filament_error.g run"

G4 P10 ; delay 10ms to debounce
if sensors.filamentMonitors[0].status="ok"
	echo "switch bounce detected - error cancelled"
	M99 ; break out if sensor value is zero again (bouncing)
echo {"Filament error type " ^ param.P ^ " detected on extruder " ^ param.D}
;M291 R"Filament Error" P{"Filament error type " ^ param.P ^ " detected on extruder " ^ param.D} S1 T3

var thisExtruderValue = move.extruders[tools[state.currentTool].filamentExtruder].position
set global.filamentDistance = var.thisExtruderValue + var.runoutDistance
echo "filament error detected - print will be paused after " ^ var.runoutDistance ^ "mm"