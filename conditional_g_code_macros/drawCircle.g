G28
M83
T0
M568 P0 A2 S240
M116
var SF = 1 ; flow rate
var FD = 1.75 ; filament diameter
var d = 0.4 ; nozzle diameter
var height = 0.25 ; layer height
G1 X0 Y{move.axes[1].max/2} Z{var.height} F1200
M400
echo "G3 I"^{min({move.axes[0].max/2},{move.axes[1].max/2})}, "X"^{move.axes[0].machinePosition}, "Y"^{move.axes[1].machinePosition}, "F800"
var radius = {move.axes[0].machinePosition} + {min({move.axes[0].max/2},{move.axes[1].max/2})}
var l = {2 * pi * var.radius}
var amount = ((var.d*var.height*var.l) + (pi*((var.height/2)*(var.height/2))*var.l)) / (pi*((var.FD/2)*(var.FD/2))) * var.SF
G3 I{min({move.axes[0].max/2},{move.axes[1].max/2})} X{move.axes[0].machinePosition} Y{move.axes[1].machinePosition} E{var.amount} F1200