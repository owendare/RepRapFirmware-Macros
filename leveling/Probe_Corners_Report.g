; Probe bed and report error
var Pitch = 0.5 ; thread pitch
M98 P"0:/sys/setDefaultProbePoints.g"
;M190 S80
M561 ; clear any bed transform
; If the printer hasn't been homed, home it
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
  G28
;G32
G30 P0 X{move.compensation.probeGrid.mins[0]} Y{move.compensation.probeGrid.mins[1]} Z-9999
var Point1 = sensors.probes[0].triggerHeight - sensors.probes[0].lastStopHeight
G30 P1 X{move.compensation.probeGrid.maxs[0]} Y{move.compensation.probeGrid.mins[1]} Z-9999
var Point2 = sensors.probes[0].triggerHeight - sensors.probes[0].lastStopHeight
G30 P2 X{move.compensation.probeGrid.maxs[0]} Y{move.compensation.probeGrid.maxs[1]} Z-9999
var Point3 = sensors.probes[0].triggerHeight - sensors.probes[0].lastStopHeight
G30 P3 X{move.compensation.probeGrid.mins[0]} Y{move.compensation.probeGrid.maxs[1]} Z-9999 S-1
var Point4 = sensors.probes[0].triggerHeight - sensors.probes[0].lastStopHeight
;M190 S-275 ; turn off bed

echo "Points are " ^ var.Point1 ^ " " ^ var.Point2 ^ " " ^ var.Point3 ^ " " ^ var.Point4
var xAvg = min(var.Point1,var.Point3) + ((max(var.Point1,var.Point3) - min(var.Point1,var.Point3)) /2)
var yAvg = min(var.Point2,var.Point4) + ((max(var.Point2,var.Point4) - min(var.Point2,var.Point4)) /2)
var aAvg = min(var.xAvg,var.yAvg) + ((max(var.xAvg,var.yAvg) - min(var.xAvg,var.yAvg))/ 2)
echo "xAvg = " ^ var.xAvg ^ " : yAvg = " ^ var.yAvg ^ " : aAvg = " ^ var.aAvg
var Highest = max(var.Point1,var.Point2,var.Point3,var.Point4)
var Lowest = min(var.Point1,var.Point2,var.Point3,var.Point4)
echo "Highest = " ^ var.Highest ^ " : Lowest = " ^ var.Lowest
echo "Adjust point 1 " ^ (var.aAvg - var.Point1) ^ "mm = " ^ floor(360/var.Pitch * (var.aAvg - var.Point1)) ^ " degrees"
echo "Adjust point 2 " ^ (var.aAvg - var.Point2) ^ "mm = " ^ floor(360/var.Pitch * (var.aAvg - var.Point2)) ^ " degrees"
echo "Adjust point 3 " ^ (var.aAvg - var.Point3) ^ "mm = " ^ floor(360/var.Pitch * (var.aAvg - var.Point3)) ^ " degrees"
echo "Adjust point 4 " ^ (var.aAvg - var.Point4) ^ "mm = " ^ floor(360/var.Pitch * (var.aAvg - var.Point4)) ^ " degrees"
