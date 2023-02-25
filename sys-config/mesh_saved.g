;0:/sys/mesh.g
; run when G29 with no paramters is called.
; if this file not found G29 S0 will run
var SafeZone = 3 ; safety margin for probing near edge.
var MinSpace = 20 ; put default minimum spacing
var MaxSpace = 60 ; put default maximum spacing

; these values are place holders aand will be calculated later
var m557MinX = 40;  ; put your default here
var m557MaxX = 180;  ; put your default here
var m557MinY = 20;  ; put your default here
var m557MaxY = 180;  ; put your default here
var ProbeCenterX = 90 ; will be updated to probe centre of print
var ProbeCenterY = 90 ; will be updated to probe centre of print
var ProbeNumX = 8 ; put default number of probe points
var ProbeNumY = 8 ; put default number probe points.


var MaxProbePoints = max(floor(move.axes[0].max / var.MaxSpace),floor(move.axes[1].max / var.MaxSpace)) ; maximum points in either axis

;echo "Maximum allowed probe points is " ^ var.MaxProbePoints ^ " using max space of " ^ var.MaxSpace


if exists(global.minProbeX)
	if global.minProbeX < max(0,sensors.probes[0].offsets[0]) + var.SafeZone
		echo "minProbeX (" ^ global.minProbeX ^ ") unreachable - reset to " ^ (sensors.probes[0].offsets[0] + var.SafeZone)
		set global.minProbeX = max(0,sensors.probes[0].offsets[0]) + var.SafeZone
	set var.m557MinX = global.minProbeX

if exists(global.maxProbeX)
	if global.maxProbeX < (global.minProbeX + (var.MinSpace*2))
		set global.maxProbeX = (global.minProbeX + (var.MinSpace*2))
	if global.maxProbeX > (move.axes[0].max - abs(sensors.probes[0].offsets[0]) - var.SafeZone)
		echo "maxProbeX (" ^ global.maxProbeX ^ ") unreachable - reset to " ^ (move.axes[0].max - sensors.probes[0].offsets[0] - var.SafeZone)
		set global.maxProbeX = move.axes[0].max - abs(sensors.probes[0].offsets[0]) - var.SafeZone
	set var.m557MaxX = global.maxProbeX

if exists(global.minProbeY)
	if global.minProbeY < max(0,sensors.probes[0].offsets[1]) + var.SafeZone
		echo "minProbeY (" ^ global.minProbeY ^ ") unreachable - reset to " ^ (sensors.probes[0].offsets[1] + var.SafeZone)
		set global.minProbeY = max(0,sensors.probes[0].offsets[1]) + var.SafeZone
	set var.m557MinY = global.minProbeY


if exists(global.maxProbeY)
	if global.maxProbeY < (global.minProbeY + (var.MinSpace*2))
		set global.maxProbeY = (global.minProbeY + (var.MinSpace*2))
	if global.maxProbeY > (move.axes[1].max - abs(sensors.probes[0].offsets[1]) - var.SafeZone)
		echo "maxProbeY (" ^ global.maxProbeY ^ ") unreachable - reset to " ^ (move.axes[1].max - sensors.probes[0].offsets[1] - var.SafeZone)
		set global.maxProbeY = (move.axes[1].max - abs(sensors.probes[0].offsets[1]) - var.SafeZone)
	set var.m557MaxY = global.maxProbeY

echo "Probing grid - X" ^ var.m557MinX ^ ":" ^ var.m557MaxX ^ " Y" ^ var.m557MinY ^ ":" ^ var.m557MaxY

var MinProbesX = floor((var.m557MaxX - var.m557MinX) / var.MaxSpace)
;echo "Min Probes X is " ^ var.MinProbesX

var MaxProbesX = floor((var.m557MaxX - var.m557MinX) / var.MinSpace)
;echo "Max Probes X is " ^ var.MaxProbesX

set var.ProbeNumX = min(var.MaxProbePoints,var.MaxProbesX)

var MinProbesY = floor((var.m557MaxY - var.m557MinY) / var.MaxSpace)
;echo "Min Probes Y is " ^ var.MinProbesY

var MaxProbesY = floor((var.m557MaxY - var.m557MinY) / var.MinSpace)
;echo "Max Probes Y is " ^ var.MaxProbesY

set var.ProbeNumY = min(var.MaxProbePoints,var.MaxProbesY)

; sanity check probe points
if var.ProbeNumX<2
	set var.ProbeNumX=2
if var.ProbeNumY<2
	set var.ProbeNumY=2

if var.ProbeNumX > var.MaxProbePoints
	set var.ProbeNumX = var.MaxProbePoints

if var.ProbeNumY > var.MaxProbePoints
	set var.ProbeNumY = var.MaxProbePoints

if (var.ProbeNumX * var.ProbeNumY) > 441
	if var.ProbeNumX > 21
		set var.ProbeNumX = 21
		echo "Too many X points - reduced to 21"
	if var.ProbeNumY > 21
		set var.ProbeNumY = 21
		echo "Too many Y points - reduced to 21"
	
echo "Probing " ^ var.ProbeNumX ^ " points in X direction & " ^ var.ProbeNumY ^ " points in Y direction"

;check state of heaters
var bedState = heat.heaters[0].state
var bedActiveTemp = heat.heaters[0].active
var bedStandbyTemp = heat.heaters[0].standby
var nozzleState = heat.heaters[1].state
M140 P0 S-276 ; turn off bed heater
M568 P0 A0 ; turn off nozzle heater

; do probing
set var.ProbeCenterX = (global.maxProbeX - ((global.maxProbeX - global.minProbeX)/2)) ; calculate centre point of probe area
set var.ProbeCenterY = (global.maxProbeY - ((global.maxProbeY - global.minProbeY)/2)) ; calculate centre point of probe area
echo "Setting Z datum point at X" ^ var.ProbeCenterX ^ " Y" ^ var.ProbeCenterY
; set Z = 0 to centre of probe area
G1 X{var.ProbeCenterX- sensors.probes[0].offsets[0]} Y{var.ProbeCenterY- sensors.probes[0].offsets[1]} Z{sensors.probes[0].diveHeight+2} F3600
G30
echo "Mesh probing"
M557 X{var.m557MinX,var.m557MaxX} Y{var.m557MinY,var.m557MaxY} P{var.ProbeNumX,var.ProbeNumY}
if result != 0
	abort "ERROR: could not create mesh" 
else
	G29 S0
	if result != 0
		abort "ERROR: Mesh probing failed"
	else
		echo "Mesh probing successful.   Loading mesh.."

; set Z = 0 to centre of probe area
echo "Reset Z datum in mesh centre"
G1 X{var.ProbeCenterX - sensors.probes[0].offsets[0]} Y{var.ProbeCenterY - sensors.probes[0].offsets[1]} Z{sensors.probes[0].diveHeight+2} F3600
G30

; turn the heaters back on if needed
if var.bedState != "off"
	M140 S{var.bedActiveTemp} R{var.bedStandbyTemp}
	if var.bedState="active"
		M144 P0 S1 ; put bed on active temp
	else
		M144 P0 S0 ; put bed on standby temp
if var.nozzleState	!= "off"
	if var.nozzleState = "active"
		M568 P0 A2 ; set nozzle to active
	else
		M568 P0 A1 ; set nozzle to standby