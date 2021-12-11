G90 ; https://duet3d.dozuki.com/Wiki/Gcode#Section_G90_Set_to_Absolute_Positioning
M280 P3 S160 I1 ; Reset BL Touch
M280 P3 S90 I1 ; Retract probe
; If the printer hasn't been homed, home it
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
	M291 P"Homing" S0 T3
	G28; Home All
else
	M291 P"No homing required." S0 T3
M400 ; https://duet3d.dozuki.com/Wiki/Gcode#Section_M400_Wait_for_current_moves_to_finish
