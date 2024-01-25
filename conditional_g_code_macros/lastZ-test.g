if move.axes[2].userPosition = 0 ; we don't know where we are, so call the macro
	M98 P"0:/macros/conditional_g_code_macros/lastZ.g" ; call the macro to create the global variable with the last known position
	if result != 0 ; the macro call was successful
		echo "macro failed"
else ; we do know where we are, so rreset the global or create it if need be
	if exists(global.LastZ)
		set global.LastZ = move.axes[2].userPosition
	else
		global LastZ = move.axes[2].userPosition
if global.lastZ < move.axes[2].max - 10
	G91 ; set relative positioning 
	G1 H2 Z10 F120
	G90 ; set absolute positioning
	echo "Z lifted"
; rest of homing file is not indented