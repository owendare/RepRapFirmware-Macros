;check if X axis is tram with bed
echo "Checking X axis bed tram"
M98 P"0:/sys/setDefaultProbePoints.g"
; get default probe speeds
var defProbes = {sensors.probes[0].speeds[0],sensors.probes[0].speeds[1]}
M558 F90 ; set probe speed to slow
var maxAllowed = 0.1 ; maximum difference
var abortPrint = true
if !move.axes[0].homed ||  !move.axes[1].homed ||  !move.axes[2].homed
    G28
    M400
var readings = vector(2,0)
G1 X0 Y{global.Bed_Center_Y} Z{sensors.probes[0].diveHeights[0]} F1800
M400
G30 S-1
G1 Z10
M400
set var.readings[0] = sensors.probes[0].lastStopHeight
G1 X190 Y{global.Bed_Center_Y} Z{sensors.probes[0].diveHeights[0]} F1800
G30 S-1
M400
G1 X{global.Bed_Center_X} Y{global.Bed_Center_Y} Z10
M400
set var.readings[1] = sensors.probes[0].lastStopHeight
M558 F{var.defProbes[0],var.defProbes[1]}
if abs(var.readings[0]-var.readings[1]) > var.maxAllowed
    if var.abortPrint
        abort "X axis not tram with bed. Error amount - " ^ abs(var.readings[0]-var.readings[1]) ^ "mm"
    else
        M118 P0 S{"WARNING: X axis not tram with bed. Error amount - " ^ abs(var.readings[0]-var.readings[1]) ^ "mm"}
else
    echo "X axis tram OK - Difference = " ^ abs(var.readings[0]-var.readings[1]) ^ "mm"
