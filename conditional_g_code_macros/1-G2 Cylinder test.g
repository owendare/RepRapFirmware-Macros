T0 P0
var CentreX = 90 ; centre of cylinder in X
var CentreY = 90 ; centre of cylinder in Y
var NozzleTemp = 220 ; nozzle temp
var bedTemp = 60 ; bed temp
var printHeight = 4 ; height of cylinder
var PrintSpeed = 40 ; speed in mm/sec,  First layer and brim will be half this
var firstLayerHeight = 0.26
var layerHeight = 0.2 ; layer height
var circlediam = 40 ; cylinder outer diameter in mm
var FanSpeed = 1 ; fan speed 0..1
var d = 0.4 ; nozzle diameter
var SF = 1 ; flow rate (0..1)
var FD = 1.75 ; filament diameter
var BrimLines = 6
var output = "0:/macros/conditional_g_code_macros/1-G2_output.g"
;echo >{var.output}
; **** don't modify after here ************
var xPoint = var.CentreX - (var.circlediam/2) - (var.d/2) ; start point allowing for diameter and nozzle size
;echo >>{var.output} "var.xPoint = " ^{var.CentreX - (var.circlediam/2) - (var.d/2)}^" ; start point allowing for diameter and nozzle size"
var yPoint = var.CentreY - (var.circlediam/2) - (var.d/2)
;var l = sqrt(((var.circlediam * pi) * (var.circlediam * pi)) + (var.layerHeight*var.layerHeight)) ; calculate length of helix
;var amount = ((var.d*var.layerHeight*var.l) + (pi*((var.layerHeight/2)*(var.layerHeight/2))*var.l)) / (pi*((var.FD/2)*(var.FD/2))) * var.SF ; calculate how many mm of filament to extrude - Owen's calculation
var l = 0
var amount = 0
;;echo "amount to extrude = " ^  var.amount
G90
G92 E0
set global.Cancelled = false
G28 ; home all
M568 P0 R140 S{var.NozzleTemp} A2
M140 S{var.bedTemp} R40
M116
G1 X0 Y0 Z{var.firstLayerHeight}
G1 E6 F120 ; extrude a blob
G10
G1 Z20 F300
M106 S{var.FanSpeed}
G1 X{var.CentreX} Y{var.CentreY} Z{var.firstLayerHeight} F3200
if var.BrimLines > 0	
	while iterations < var.BrimLines -1
		var BrimX = var.CentreX - (var.circlediam/2) + (var.d/2) - ((var.BrimLines-iterations)*var.d))
		var BrimY = var.xPoint-((var.BrimLines*var.d) - (iterations*var.d))
		var BrimRadius = (var.circlediam/2) +  (var.BrimLines-iterations)*var.d) - (var.d/2)
		if !exists(var.l)
			var.l=0
		set var.l = sqrt(((var.BrimRadius * 2 * pi) * (var.BrimRadius* 2 * pi)) + (var.layerHeight*var.layerHeight)) ; calculate length of helix
		if !exists(var.amount)
			var amount=0
		set var.amount = ((var.d*var.layerHeight*var.l) + (pi*((var.layerHeight/2)*(var.layerHeight/2))*var.l)) / (pi*((var.FD/2)*(var.FD/2))) * var.SF ; calculate how many mm of filament to extrude - Owen's calculation
		G1 X{var.BrimX} Y{var.CentreY} Z{var.firstLayerHeight} F3200
;		echo >>{var.output} "G1 X",{var.BrimX}," Y",{var.CentreY}," Z",{var.firstLayerHeight}," F3200"
		G2 X{var.BrimX} Y{var.CentreY} I{var.CentreX-var.BrimX} J0 E{var.amount*1.1} F{var.PrintSpeed*60/2}
;		echo >>{var.output} "G2 X",{var.BrimX}," Y",{var.CentreY}," I",{var.CentreX-var.BrimX}," J0 E",{var.amount}," F",{var.PrintSpeed*60/2}
		if result !=0
			abort "Brim move not possible"
G10
set var.l = sqrt(((var.circlediam * pi) * (var.circlediam * pi)) + (var.layerHeight*var.layerHeight)) ; calculate length of helix
set var.amount = ((var.d*var.layerHeight*var.l) + (pi*((var.layerHeight/2)*(var.layerHeight/2))*var.l)) / (pi*((var.FD/2)*(var.FD/2))) * var.SF ; calculate how many mm of filament to extrude - Owen's calculation
G1 X{var.xPoint} Y{var.CentreY} Z{var.firstLayerHeight} F3200
;echo >>{var.output} "X",{var.xPoint}," Y",{var.CentreY}," Z",{var.firstLayerHeight}," F3200"
G11
G2 X{var.xPoint} Y{var.CentreY} Z{var.firstLayerHeight} I{var.CentreX-var.xPoint} J0 E{var.amount} F{var.PrintSpeed*60/2}
if result !=0
	abort "Move not possible"
;echo >>{var.output} "G2 X",{var.xPoint}," Y",{var.CentreY}," Z",{var.firstLayerHeight}," I",{var.CentreX-var.xPoint}," J0 E",{var.amount}," F",{var.PrintSpeed*60/2}
;echo >>{var.output} "User position before loop is Z=" , {move.axes[2].userPosition}
while move.axes[2].userPosition < var.printHeight
;	echo >>{var.output} "User position before move is Z=" , {move.axes[2].userPosition}
;	echo >>{var.output} "G2 X",{var.xPoint}," Y",{var.CentreY},"  I",{var.CentreX-var.xPoint}," J0 Z",{move.axes[2].userPosition + var.layerHeight}," E"^{var.amount}," F",{var.PrintSpeed*60}
	G2 X{var.xPoint} Y{var.CentreY}  I{var.CentreX-var.xPoint} J0 Z{move.axes[2].userPosition + var.layerHeight} E{var.amount} F{var.PrintSpeed*60}
	if result !=0
		abort "Move not possible"
;	echo >>{var.output} "User position after move is Z" , {move.axes[2].userPosition}
G10
G1 X{var.CentreX} Y{var.CentreY} Z{move.axes[2].userPosition + 10}
M400
M106 S0
M568 P0 A0
M140 S-273.1
M29