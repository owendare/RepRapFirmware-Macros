; pause.g
; called when a print from SD card is paused
;
; generated by RepRapFirmware Configuration Tool v2.1.4 on Sat Jan 04 2020 09:46:45 GMT+1000 (Australian Eastern Standard Time)
M83            ; relative extruder moves
G91		; relative movement
if global.filamentIsFlexible = false
	G10  ; retract filament
G1 Z+5 F600     ; lift Z by 5mm
G90            ; absolute positioning
G1 X{move.axes[0].min+5} Y{move.axes[1].max-5} F6000 ; move bed forward and clear nozzle away
;M144 ; put bed on standby
M568 P{state.currentTool} A1 ; Put nozzle in standby