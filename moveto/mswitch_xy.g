;;
;; *ADJUST* these coordinates for your mechanical switch position

G90                             ; absolute positioning
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
	M291 P"Homing" S0 T3
	G28; Home All
G1 X{move.axes[0].min} Y{move.axes[1].min} F3000             ; move to directly above mechanical Z-switch
