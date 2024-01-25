; stop.g
; called when M0 (Stop) is run (e.g. when a print from SD card is cancelled)
;
;
;M929 P"0:/sys/stoplog.txt" S3 ; start logging to file eventlog.txt
set global.Cancelled = true
if {state.currentTool!=-1} ; check if any tools are active
	if #tools[state.currentTool].heaters > 0 & heat.heaters[tools[state.currentTool].heaters[0]].current > heat.coldRetractTemperature
		G91 ; relative positioning
		if global.filamentIsFlexible = false
			G1 E-1 F1800 ; retract the filament a bit before lifting the nozzle to release some of the pressure
			M291 P"Retracted 1mm" R"Retracting" S0 T3
			G4 S4 ; wait for popup
		G90 ; back to absolute positioning
	else
		M291 P{"Not retracted...  Heater off or below extrude temp  " ^ heat.heaters[1].current ^ " : " ^ heat.coldRetractTemperature ^ "."} R"Retract" S0 T5
		G4 S6 ; wait for popup
else
	M291 P"No active tool" R"Check tools" S0 T3

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


;T-1 P0; deselect all tools but don't run tool change macros

M106 P0 S0 ; part fan off
M84 ; steppers off
G90 ; absolute positioning

M220 S100 ; Set speed factor to 100%

while iterations < #move.extruders
	M221 S100 D{iterations} ;set extrusion to 100% on all extruders

;M290 R0 S0 ; clear babystepping

G29 S2 ; clear bed height map (disables bed compensation)

M98 P"0:/sys/setDefaultProbePoints.g"            ; re-define mesh grid in case it was altered


set global.RunDaemon = false ; the daemon interferes with the music
M98 P"0:/macros/songs/itchyscratchy.g" ; play finish tune
set global.RunDaemon = true
set global.Cancelled = false

M291 P"Shut down complete - powering down" R"Finished" S0 T6
M42 P5 S0 ; turn off LED strip driven by P5 output
M81 S1 ; Wait for hotend to cool before turning off power
echo >>"0:/sys/print_log.txt" "Print job finished at", state.time
echo >>"0:/sys/print_log.txt" "**********************************"

;M929 S0 ; stop logging
