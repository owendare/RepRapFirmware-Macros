; get_probe_offset.g
; determine probe offset

if state.atxPower = false
	M80
	G4 S4
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
	G28
	G1 Z60
	M400
M291 P"Prepare" R"Place & secure paper on bed" S3 ;
G1 X{global.Bed_Center_X} Y{global.Bed_Center_Y} Z5
M400
M291 P"Jog nozzle to touch paper and mark position on paper" R"Move" S3 Z1 ;
M400
G1 Z10
M98 P"0:/sys/deployprobe.g"
var xPos = move.axes[0].machinePosition;
var yPos = move.axes[1].machinePosition;
M291 P"Jog sensor pin over mark" R"Move" S3 X1 Y1 Z1 ;
M400
var xPinPos = move.axes[0].machinePosition
var yPinPos = move.axes[1].machinePosition
var xOffset = var.xPos - var.xPinPos
var yOffset = var.yPinPos - var.yPos 
M291 P{"Values are X" ^ var.xOffset ^ " Y" ^ var.yOffset} R"Store results?" S3
G31 X{var.xOffset} Y{var.yOffset}
M500 P31 ;
echo "Offsets stored"
M98 P"0:/sys/retractprobe.g"
M291 P"Run Z probe height calibration?" R"Do Z height calibration?" S3
M98 P"0:/macros/bl_touch/call_calibrate_BLtouch.g"
