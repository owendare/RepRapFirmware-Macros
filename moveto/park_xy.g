;; Move to a safe and convenient parking location.
;; Useful for when a print is finished.
;; By moving only on X and Y and not Z,
;; it's a safer way to get out of the way no matter how tall your print is.
;; (Unfortunately it's not quite as convenient for short prints as also moving way up in Z.)
;;
;; *ADJUST* these coordinates based on your build volume
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
	M291 P"Homing" S0 T3
	G28; Home All
G90                             ; absolute positioning
G1 X{move.axes[0].min + 15} Y{move.axes[1].max - 15} F6000              ; move to center rear of build space
