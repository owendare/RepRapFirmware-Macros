;CANCEL.G  Run when print is cancelled or M1 called
; called when a print is cancelled after a pause.
echo "cancel.g called"
set global.Cancelled = true

if heat.heaters[1].current > heat.coldRetractTemperature
	if global.filamentIsFlexible = false
		G10 ; retract the filament a bit before lifting the nozzle to release some of the pressure
else
	M291 P"Extruder temp too low to retract" R"Retracting" S0 T2

if {!move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed} ; check if the machine is homed
	M291 P"Insufficient axis homed.  Cannot raise or park" R"Parking" S0 T3
else
	if {(move.axes[2].machinePosition) < (move.axes[2].max - 10)} ; check if there's sufficient space to raise head
		M291 P{"Raising head to...  Z" ^ (move.axes[2].machinePosition+5)}  R"Raising head" S0 T2
		G91 ; relative positioning
		G1 Z5 F120 ; move Z up a bit
		G90 ;absolute positioning
	else
		M291 P{"Cannot raise head - insufficient space  " ^ move.axes[2].machinePosition ^ " : " ^ (move.axes[2].max - 10) ^ "."} R"Raising head" S0 T3
	G4 S4 ; wait for popup to display
	G90 ;Absolute positioning
	M291 P{"Parking head at X:" ^ (move.axes[0].min + 15) ^ " Y:" ^ (move.axes[1].max - 15)} R"Parking" S0 T3
	G1 X{move.axes[0].min + 15} Y{move.axes[1].max - 15} F1800; parks X head pushes bed out to front so you can pull part
	M400 ; wait for current moves to finish

; Shut down all tool heaters and set temps to zero.
M98 P"0:/macros/heating/all_tool_heaters_off.g"

;Shut down all chamber heaters
M98 P"0:/macros/heating/all_chamber_heaters_off.g"

;Shut down all bed heaters
M98 P"0:/macros/heating/all_bed_heaters_off.g"


M106 P0 S0 ; part fan off

G90 ; absolute positioning
if move.axes[0].homed && move.axes[1].homed && move.axes[2].homed
	G1 X{move.axes[0].min} Y{move.axes[1].max} ; parks X head pushes bed out to front so you can pull part
G4 S1 ; wait for moves to finish
;M84 ; steppers off
M98 P"0:/sys/setDefaultProbePoints.g"
M291 P"Print cancelled" R"Cancelled" S0 T2
set global.RunDaemon = false ; the daemon interferes with the music
M98 P"0:/macros/songs/itchyscratchy.g" ; play finish tune
set global.RunDaemon = true 
set global.Cancelled = false
echo >>"0:/sys/print_log.txt" "Print job cancelled at", state.time
echo >>"0:/sys/print_log.txt" "**********************************"