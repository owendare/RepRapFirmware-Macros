;0:/sys/filament-error#.g
; run when filament error for extruder # is found.
; if this file not found runs filament-error.g
; if neither found runs pause.g
G4 P10 ; delay 10ms to debounce
if sensors.filamentMonitors[0].status="ok"
	echo "switch bounce detected"
	M99 ; break out if sensor value is zero again (bouncing)
var runoutDistance = 300 ; this is just so you can change easily 
var thisExtruderValue = move.extruders[tools[state.currentTool].filamentExtruder].position
set global.filamentDistance = var.thisExtruderValue + var.runoutDistance
echo "filament-error0.g run - print will be paused after " ^ var.runoutDistance ^ "mm"
;M98 P"0:/sys/pause.g" ; pause print 