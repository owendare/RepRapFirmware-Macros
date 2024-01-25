;; There's nothing special about the center,
;; but it's a convenient place to go
;; to give the user access to both the bed and the X-carriage.
;;
;; *ADJUST* these coordinates based on your build volume

G90                             ; absolute positioning
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
	M291 P"Homing" S0 T3
	G28; Home All
G1 X{global.Bed_Center_X} Y{global.Bed_Center_Y} Z{move.axes[2].max / 2} F5000       ; move to a centerpoint
