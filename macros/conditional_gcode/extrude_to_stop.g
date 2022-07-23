; extrude_to_stop.g
; Parameters can be passed to macro.  e.g. 
;M98 P"extrude_to_stop.g" A0.05 R100 S100 Q200 T1 M1 C0 B0

; adjust defaults as required.  
var minVoltage = 23.8 ; set to minimum acceptable voltage.  Change to suit your system
var extrudeDistance = 1 ; amount extruded with each iteration until stop is detected. Over-ridden if parameter "A" passed
var retractDistance = 50 ; amount to retract after stop detected. Over-ridden if parameter "R" passed
var extrudeSpeed = 320 ; speed in MM/min to extrude. Over-ridden if parameter "S" passed
var retractSpeed = 600 ; speed in MM/min to retract. Over-ridden if parameter "Q" passed
var cancelAmount = 30 ; maximum extrusion amount before macro cancels.  This should stop an endless loop
var amountExtruded = 0 ; storage for counter
var whichTool = 0 ; assume tool 0 to start. Over ridden if parameter "T" passed
var whichSensor = 0 ; assume sensor number is 0 to start Over-ridden if parameter "M" passed
var doToolChange = 0 ; Over-ridden if parameter "C" passed (C0 or C1)
var whichDrive = 0 ; Over-ridden if parameter "B" passed
var sensorState = 0 ; sensor state when macro run

; check that we have power
if (state.atxPower != null)
	if state.atxPower = false
		M80 ; turn on ATX power
		G4 S3 ; wait a few seconds to power up

;echo "check voltage"
if (boards[0].vIn.current) < (var.minVoltage)
	abort "ABORT: Voltage too low for motor movement"

; check if parameters have been passed and adjust variables accordingly
if exists(param.A)
	set var.extrudeDistance = param.A

if exists(param.R)
	set var.retractDistance = param.R

if exists(param.S)
	set var.extrudeSpeed = param.S

if exists(param.Q)
	set var.retractSpeed = param.Q

if exists(param.T)
	set var.whichTool=param.T
	
if exists(param.M)
	set var.whichSensor = param.M
	
if exists(param.C)
	set var.doToolChange = param.C

if exists(param.B)
	set var.whichDrive = param.B



T{var.whichTool} P{var.doToolChange} ; select tool and run toolchange macros if required

; check if the filament sensor is enabled and record it for resetting to original later
if (sensors.filamentMonitors[var.whichSensor].enabled != true)
	M591 D{var.whichDrive} P1 ; enable the filament monitor
	set var.sensorState = 0
else
	set var.sensorState = 1

; make sure sensor filament isn't already detected
if sensors.filamentMonitors[var.whichSensor].status = "ok"
	M118 S"Filament is already detected.  Macro cancelled" P0 L1
	M291 R"Error" P"Filament is already detected.  Macro cancelled" T1 S3
	M591 D{whichDrive} S{sensorState} ; reset sensor state
	M99 ; exit macro


; start the movement section
M83 ; relative extrusion
M302 P1; allow cold extrude
M291 P"Press OK to begin" R"Ready?" S3 ; wait for user action
while (sensors.filamentMonitors[var.whichSensor].status != "ok") && (var.amountExtruded < var.cancelAmount)
	G1 E{var.extrudeDistance} F{var.extrudeSpeed}
	if result != 0 ; check if command was succesful
		var.amountExtruded = var.cancelAmount ; cancel out if there was a problem in the move command
		break ; exit the loop
	set var.amountExtruded = var.amountExtruded + var.extrudeDistance ; increment the counter to track how far we've moved
	M400 ; wait for move to finish before starting loop again
	M291 P{"Filament fed:  " ^ var.amountExtruded ^ "mm"} S0 T0.5

if var.amountExtruded >= var.cancelAmount
	M118 S"Extrusion limit reached or error occured - macro cancelled" P0 L1
	M291 P"Extrusion limit reached or error occured - macro cancelled" R"Error"	S0 T3
	M302 P0; Dissallow cold extrusion again
	M591 D{var.whichDrive} S{var.sensorState} ; reset sensor state
	M99 ; exit macro


; if we got this far the limit switch has been tripped
M291 P{"Limit switch found after " ^ var.amountExtruded ^ "mm. Retracting " ^ var.retractDistance ^ "MM"} R"Retracting" S1 T3
G4 S3 ; Delay for a few seconds	for popup to expire
G1 E{0 - var.retractDistance} F{var.retractSpeed}
M400 ; wait for move to complete

M591 D{whichDrive} S{sensorState} ; reset sensor state
M302 P0; Dissallow cold extrusion again

M291 P"Filament in position" R"Done" S1 T3