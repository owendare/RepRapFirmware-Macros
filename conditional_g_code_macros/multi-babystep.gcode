;save_babystep.g
; Add babystep to Z offset and make "persistant"

if state.status="processing"
	abort

; If the printer hasn't been homed, home it
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
  G28


while iterations < 9
	M290 S-0.1

	if move.axes[2].babystep !=0
		G29 S2 ; clear bed mesh compensation
		;G90 ; set to absolute positioning
		echo {"Z trigger height altered by " ^ move.axes[2].babystep ^  "mm"}
		echo {"Old: " ^ sensors.probes[0].triggerHeight ^ " New: " ^ sensors.probes[0].triggerHeight - move.axes[2].babystep}
		G31 Z{(sensors.probes[0].triggerHeight) - (move.axes[2].babystep)}
		M500 P31:10
		M290 R0 S0 ; clear babystepping
		G4 S2


	else
		echo "No babystepping set.  Nothing to save"