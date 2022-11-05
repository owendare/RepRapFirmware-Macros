;0:/sys/driver-stall.g
echo " A driver stall has occured on driver " ^ param.D
echo "Layer shifting may have occured at X:",move.axes[0].machinePosition, "Y:", move.axes[1].machinePosition, "Z:", move.axes[2].machinePosition
echo "Requested speed is " , move.currentMove.requestedSpeed, "mm/sec. Top speed is", move.currentMove.topSpeed, "mm/sec"
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
	G1 F1200 ; reduce speed when travelling back to saved slot
	G1 R3 X0 Y0 Z5; travel to 5mm above stall position
	M400
	G1 F60 ; reduce speed
	G1 R3 X0 Y0 Z0 ; move to stall position
	M400
	; if a tool is selected and the heater is up to temp, we'll un-retract if required.
	if (heat.heaters[tools[max(state.currentTool,0)].heaters[0]].current > heat.coldExtrudeTemperature) && (tools[max(state.currentTool,0)].isRetracted)
		G11
	set global.InMacro = false ; unset the flag