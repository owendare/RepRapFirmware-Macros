;CANCEL.G  Run when print is cancelled or M1 called
; called when a print is cancelled after a pause.
echo "cancel.g called"
M291 P"Shutting down heaters" R"Heaters" S0 T1
G4 S1.1 ; wait for popup
while #tools > iterations
	if (tools[iterations]!=null) && (#tools[iterations].heaters >0)
		M568 P{iterations} S0 R0
		M568 P{iterations} A0 ; Set active and standby temps to zero & turn off heaters
		M291 P{"Tool " ^ (iterations) ^ " is set to " ^ heat.heaters[tools[0].heaters[0]].state} S0 T1.5
		G4 S1.6 ; wait for popup

while iterations < #heat.chamberHeaters
	if heat.chamberHeaters[iterations]!=-1
		M141 P{iterations}S0 R0 ;set chamber temp to zero
		M141 P{iterations} S-275 ; chamber heater off
		M291 P{"Chamber # " ^ iterations ^ " off"} S0 T1

while iterations < #heat.bedHeaters
	if heat.bedHeaters[iterations] !=-1
		M140 P{iterations} S0 R0 ; make bed temp zero
		M140 P{iterations} S-275 ; bed off
		M291 P{"Bed # " ^ iterations ^ " off"} S0 T1
		G4 S1.1 ; wait for popup

M106 P0 S0 ; part fan off
if heat.heaters[1].current > heat.coldRetractTemperature
	G10 ; retract the filament a bit before lifting the nozzle to release some of the pressure
	if move.axes[0].homed && move.axes[1].homed && move.axes[2].homed
		G91 ; relative positioning
		G1 Z+1.5 F9000 ; move Z up a bit and retract filament
else
	M291 P"Extruder temp too low to retract" R"Retracting" S0 T2
G90 ; absolute positioning
if move.axes[0].homed && move.axes[1].homed && move.axes[2].homed
	G1 X{move.axes[0].min} Y{move.axes[1].max} ; parks X head pushes bed out to front so you can pull part
G4 S1 ; wait for moves to finish
M84 ; steppers off
M557 X40:180 Y20:160 S20  ; re-define mesh grid
M291 P"Print cancelled" R"Cancelled" S0 T2
M98 P"0:/macros/songs/itchyscratchy.g" ; play finish tune