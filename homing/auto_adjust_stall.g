;auto_adjust_stall.g
; Must be called from dist2home.g
; do not run as stand alone
; NOTE:  Values are not stored between boots.
; values must be applied to config.g when satisfied they capture valid stalls without false positives
; Axis diver number must be passed as D parameter

; array containing initial M915 values for X and Y drivers first value is S (threshold) second is H
; set initial values here.  Must be manually set as not available from object model
; should match your config.g initially

var stallVals = {{4,250},{4,200}}

; values to change and amounts to change by.  Also min/max allowed	
var increaseS = true ; adjust M915 S parameter true/false
var amountS = 1 ; amount to adjust (increase) by on each stall event
var maxS = 8 ; maximum allowed value before auto adjust stops applying
var increaseH = true ; adjust M915 H parameter true/false
var amountH = 4 ; amount to adjust (increase) by on each stall event
var maxH = 300 ; maximum allowed value before auto adjust stops applying
var reduceJerk = true ; adjust (reduce) jerk value on stall event true/false
var amountJerk = 10 ; amount to adjust (decrease) jerk on each stall event
var minJerk = 500 ; minimum jerk value allowed before auto adjust stops applying
var reduceAccel = true ;adjust (reduce) acceleration value on stall event true/false
var amountAccel = 20 ;amount to adjust (decrease) acceleration on each stall event
var minAccel = 600 ; ; minimum jerk value allowed before auto adjust stops applying


var logFile =  "0:/sys/driver_stall_log.txt" ; file to log changes to
if !fileexists(var.logFile)
	echo >{var.logFile} "File created : " ^ state.time

if !exists(param.D)
	echo "No D parameter passed.  Auto stall adjust not carried out"
	M99

; ensure driver number resolves to X or Y (assumes x & Y are axes 0 & 1)
var thisAxis = ""
var validDriver = false
while iterations < #move.axes[0].drivers
	if (move.axes[0].drivers[iterations]) == {""^param.D^""}
		set var.validDriver = true
		set var.thisAxis = "X"

while iterations < #move.axes[1].drivers
	if (move.axes[1].drivers[iterations]) == {""^param.D^""}
		set var.validDriver = true
		set var.thisAxis = "Y"

if (var.validDriver = false) || (var.thisAxis = "")
	echo "Only X and Y axis supported - Auto stall not adjusted"
	M99


echo "Axis to adjust is " ^ var.thisAxis
	
; Store the stall values in a global so they are persistant between events
; It will be updated each time the macro runs after that
if !exists(global.M915vals)
	global M915vals = var.stallVals 
	if var.thisAxis = "X"
		M915 X S{global.M915vals[0][0]} H{global.M915vals[0][1]}
	if var.thisAxis = "Y"
		M915 X S{global.M915vals[1][0]} H{global.M915vals[1][1]}	
echo "Current M915 values..."
M915
G4 P200
		

echo >>{var.logFile} "******************************"
echo >>{var.logFile} "Auto stall adjust called at " ^ state.time

if var.thisAxis = "X"
	G4 P100
	if global.M915vals[0][0] >= var.maxS
		G4 P200
		echo "Maximum S value reached - no further adjustment will occur"
	if global.M915vals[0][1] >= var.maxH
		G4 P100
		echo "Maximum H value reached - no further adjustment will occur"
	if (var.increaseS = true) && (global.M915vals[0][0] <= (var.maxS-var.amountS)) ; see if values should be increased
		set global.M915vals[0][0] = global.M915vals[0][0] + var.amountS
		G4 P100
		echo "S param set to " ^ global.M915vals[0][0]
	if var.increaseH = true && (global.M915vals[0][1] <= (var.maxH-var.amountH))
		set global.M915vals[0][1] = global.M915vals[0][1] + var.amountH
	if (var.increaseS = true) || (var.increaseH = true) ; check if new values must be applied
		M915 X S{global.M915vals[0][0]} H{global.M915vals[0][1]} ; set new values
		echo >>{var.logFile} "New X axis M915 values set - S=" ^ global.M915vals[0][0] ^ " H=" ^ global.M915vals[0][1]
		G4 P200
		echo "New M915 values are..."
		G4 P200
		M915 ; echo new values to console
	G4 P200
	if (var.reduceJerk = true) && (move.axes[0].jerk >= (var.minJerk + var.amountJerk)) ; see if jerk is to be reduced
		M566 X{move.axes[0].jerk - var.amountJerk} 
		echo >>{var.logFile} "X jerk reduced to " ^ {move.axes[0].jerk - var.amountJerk}
		G4 P200
		M566

	if (var.reduceAccel = true) && (move.axes[0].acceleration >= (var.minAccel + var.amountAccel)) ; see if acceleration is to be reduced
		M201 X{move.axes[0].acceleration - var.amountAccel} 
		echo >>{var.logFile} "X acceleration reduced to " ^ {move.axes[0].acceleration - var.amountAccel}
		G4 P100
		M201
	
if var.thisAxis = "Y"
	if global.M915vals[1][0] >= var.maxS
		G4 P100
		echo "Maximum S value reached - no further adjustment will occur"
	if global.M915vals[1][1] >= var.maxH
		G4 P100
		echo "Maximum H value reached - no further adjustment will occur"
	if (var.increaseS = true) && (global.M915vals[0][0] <= (var.maxS-var.amountS)) ; see if values should be increased
		set global.M915vals[1][0] = global.M915vals[1][0] + var.amountS
	if var.increaseH = true && (global.M915vals[1][1] <= (var.maxH-var.amountH))
		set global.M915vals[1][1] = global.M915vals[1][1] + var.amountH
	if (var.increaseS = true) || (var.increaseH = true) ; check if new values must be applied
		M915 Y S{global.M915vals[1][0]} H{global.M915vals[1][1]} ; set new values
		G4 P200
		echo >>{var.logFile} "New Y axis M915 values set - S=" ^ global.M915vals[1][0] ^ " H=" ^ global.M915vals[1][1]
		G4 P100
		echo "New M915 values are..."
		G4 P200
		M915 ; echo new values to console
	G4 P100
	if (var.reduceJerk = true) && (move.axes[1].jerk >= (var.minJerk + var.amountJerk)) ; see if jerk is to be reduced
		M566 Y{move.axes[1].jerk - var.amountJerk} 
		echo >>{var.logFile} "Y jerk reduced to " ^ {move.axes[1].jerk - var.amountJerk}
		G4 P200
		M566
	
	if (var.reduceAccel = true) && (move.axes[1].acceleration >= (var.minAccel + var.amountAccel)) ; see if acceleration is to be reduced
		M201 Y{move.axes[1].acceleration - var.amountAccel} 
		echo >>{var.logFile} "Y acceleration reduced to " ^ {move.axes[1].acceleration - var.amountAccel}
		G4 P100
		M201
		



