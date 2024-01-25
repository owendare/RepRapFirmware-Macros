; 0:/sys/filament-change.g
; runs when M600 is called in preference to pause.g
M98 P"0:/sys/checkATX.g"
M83            ; relative extruder moves
G91		; relative movement
G10  ; retract filament
G1 Z+5 F600     ; lift Z by 5mm
G90            ; absolute positioning
G1 X{move.axes[0].min} Y{move.axes[1].max} F6000 ; move bed forward and clear nozzle away
M144 ; put bed on standby
echo "Printer state is: " , state.status
if move.extruders[state.currentTool].filament == ""
	M98 P"0:/macros/filament/universal_unload.g"
else
	M702
