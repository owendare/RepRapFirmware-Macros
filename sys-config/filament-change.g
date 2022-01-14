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
if move.extruders[state.currentTool].filament == ""
	M291 R"Setting temp" P"Waiting to reach retract temp" S0 T5
	M116 ; wait for temps
	M98 P"0:/macros/filament/universal-unload.g"
else
	M702