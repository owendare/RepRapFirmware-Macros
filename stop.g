; stop.g
; called when M0 (Stop) is run (e.g. when a print from SD card is cancelled)
;
;
;M929 P"0:/sys/stoplog.txt" S3 ; start logging to file eventlog.txt
set global.Cancelled = true
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


if {state.currentTool!=-1} ; check if any tools are active
	G91 ; relative positioning
	if #tools[state.currentTool].heaters > 0 & heat.heaters[tools[state.currentTool].heaters[0]].current > heat.coldRetractTemperature
		G1 E-2 F300 ; retract the filament a bit before lifting the nozzle to release some of the pressure
		M291 P"Retracted 2mm" R"Retracting" S0 T5
		G4 S6 ; wait for popup
	else
		M291 P{"Not retracted...  Heater off or below extrude temp  " ^ heat.heaters[1].current ^ " : " ^ heat.coldRetractTemperature ^ "."} R"Retract" S0 T5
		G4 S6 ; wait for popup
else
	M291 P"No active tool" R"Check tools" S0 T3

; Shut down all tool heaters and set temps to zero.
M291 P"Shutting down tool heaters" R"Heaters" S0 T1
G4 S1.1 ; wait for popup
var ToolsDone = 1 ; create a variable to cope with tools that are not sequentially numbered (unlikely but possible)
while (iterations < limits.tools) && (var.ToolsDone < #tools) 
	echo "iteration " ^ iterations
	if (tools[iterations]!=null)
		echo #tools[iterations].heaters ^ " on tool " ^ iterations
		if (#tools[iterations].heaters > 0) ; check if the tool has a heater to turn off
			M568 P{iterations} S0 R0 ; Set active and standby to zero
			M568 P{iterations} A0 ; turn off heater(s) associated with this tool
			M291 P{"Tool " ^ (iterations) ^ " is set to off" } S0 T1.5 ; report heater state of tool
			G4 S1.6 ; wait for popup
		set var.ToolsDone = var.ToolsDone + 1 ; Increment the number of tools shut off.
	else
		echo "Null value Tool number - skipping #" ^ iterations
		G4 S1
		continue ; we've encountered a non sequential move to next tool number without incrementing the ToolsDone variable

M291 P"Shutting down chamber heaters" R"Heaters" S0 T1
G4 S1.1 ; wait for popup
while iterations < #heat.chamberHeaters
	;echo "checking chamber heater " ^ iterations-1
	if heat.chamberHeaters[iterations]!=-1
		M141 P{iterations} S0 R0
		M141 P{iterations} S-276
		M291 P{"Chamber # " ^ iterations ^ " off"} R"Heaters" S0 T1

M291 P"Shutting down bed heaters" R"Heaters" S0 T1
G4 S1.1 ; wait for popup
while iterations < #heat.bedHeaters
	if heat.bedHeaters[iterations] !=-1
		M140 P{iterations} S0 R0
		M140 P{iterations} S-276
		M291 P{"Bed heater # " ^ iterations ^ " off"} R"Heaters" S0 T1
		G4 S1.1 ; wait for popup




;T-1 P0; deselect all tools but don't run tool change macros

M106 P0 S0 ; part fan off
M84 ; steppers off
G90 ; absolute positioning

M220 S100 ; Set speed factor to 100%

while iterations < #move.extruders
	M221 S100 D{iterations} ;set extrusion to 100% on all extruders

M290 R0 S0 ; clear babystepping

G29 S2 ; clear bed height map (disables bed compensation)

M557 X40:180 Y0:180 S20              ; re-define mesh grid in case it was altered



M98 P"0:/macros/songs/itchyscratchy.g" ; play finish tune


M291 P"Shut down complete - powering down" R"Finished" S0 T6
M42 P5 S0 ; turn off LED strip driven by P5 output
M81 S1 ; Wait for hotend to cool before turning off power

;M929 S0 ; stop logging
