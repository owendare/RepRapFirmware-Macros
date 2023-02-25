;0:/sys/driver-stall.g
var yMotorTemp = {sensors.analog[5].lastReading  * 1.00}
var xMotorTemp = {sensors.analog[4].lastReading * 1.00}
var xDriver = 4
var yDriver = 1

if (param.D = var.xDriver)  || (param.D = var.yDriver)
	set var.yMotorTemp = sensors.analog[5].lastReading; get the current motor temp
	set var.xMotorTemp = sensors.analog[4].lastReading; get the current motor temp
	echo "X motor temp =", var.xMotorTemp ^ "C" , " : Y motor temp =", var.yMotorTemp ^ "C"

echo " A driver stall has occured on driver " ^ param.D
echo "Layer shifting may have occured at X:",move.axes[0].machinePosition, "Y:", move.axes[1].machinePosition, "Z:", move.axes[2].machinePosition
echo "Requested speed is " , move.currentMove.requestedSpeed, "mm/sec. Top speed is", move.currentMove.topSpeed, "mm/sec"
if (var.xMotorTemp !=0) || (var.yMotorTemp !=0)
	echo "X motor temp =", var.xMotorTemp ^ "C" , " : Y motor temp =", var.yMotorTemp ^ "C"
	
echo >>"0:/sys/print_log.txt" "A driver stall has occured on driver " ^ param.D
echo >>"0:/sys/print_log.txt"  "Layer shifting may have occured at X:",move.axes[0].machinePosition, "Y:", move.axes[1].machinePosition, "Z:", move.axes[2].machinePosition
echo >>"0:/sys/print_log.txt"  "Requested speed is " , move.currentMove.requestedSpeed, "mm/sec. Top speed is", move.currentMove.topSpeed, "mm/sec"
if (var.xMotorTemp !=0) || (var.yMotorTemp !=0)
	echo >>"0:/sys/print_log.txt"  "X motor temp =", var.xMotorTemp ^ "C" , " : Y motor temp =", var.yMotorTemp ^ "C"
echo >>"0:/sys/print_log.txt" "**********************************"	
; check if a driver stall is already being acted on.
if global.InMacro=true
	echo "Driver stall macro already running - no further action taken"
	M99 ; exit macro
M400

	
if job.file.fileName!= null ; check if we are printing
	set global.InMacro=true	; stop the mcro being run multiple times
	G60 S3 ; save position to slot 3
	echo "File position is ", job.filePosition, "bytes"
	echo "Physical position is X:",move.axes[0].machinePosition, "Y:", move.axes[1].machinePosition, "Z:", move.axes[2].machinePosition
	G4 P5
	; if a tool is selected and the heater is up to temp we'll retract
	if heat.heaters[tools[max(state.currentTool,0)].heaters[0]].current > heat.coldRetractTemperature
		G10
	G1 F1800 ; reduce speed before homing
	G28 X Y ; home X & Y
	M400
	M116
	set global.InMacro = false ; unset the flag so it will start looking for stalls on the return
	G1 F1200 ; reduce speed when travelling back to saved slot
	G1 R3 X0 Y0 Z5; travel to 5mm above stall position
	G1 F60 ; reduce speed
	G1 R3 X0 Y0 Z0 ; move to stall position
	; if a tool is selected and the heater is up to temp, we'll un-retract if required.
	if (heat.heaters[tools[max(state.currentTool,0)].heaters[0]].current > heat.coldExtrudeTemperature) && (tools[max(state.currentTool,0)].isRetracted)
		G11
	