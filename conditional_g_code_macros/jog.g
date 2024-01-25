M291 P"Jog to position" S3 X1 Y1 Z1
M400
G4 P500
var xPos = move.axes[0].machinePosition
var yPos = move.axes[1].machinePosition
var zPos = move.axes[2].machinePosition
echo "Machine positions are X" ^ var.xPos ^ " Y" ^ var.yPos ^ " Z" ^ var.zPos
set var.xPos = move.axes[0].userPosition
set var.yPos = move.axes[1].userPosition
set var.zPos = move.axes[2].userPosition
echo "User positions are X" ^ var.xPos ^ " Y" ^ var.yPos ^ " Z" ^ var.zPos
