;0:/sys/mesh.g
; run when G29 with no paramters is called.
; if this file not found G29 S0 will run
var m557MinX = 40;  ; put your default here
var m557MaxX = 180;  ; put your default here
var m557MinY = 20;  ; put your default here
var m557MaxY = 180;  ; put your default here
var MinSpace = 10 ; put default minimum spacing
var MaxSpace = 30 ; put default maximum spacing
var ProbeNumX = 8 ; put default probe points
var ProbeNumY = 8 ; put default probe points.

var MaxProbePoints = max(floor(move.axes[0].max / var.MaxSpace),floor(move.axes[1].max / var.MaxSpace)) ; maximum points in either axis

echo "Maximum allowed probe points is " ^ var.MaxProbePoints ^ " using max space of " ^ var.MaxSpace
var SafeZone = 3 ; safety margin for probing near edge.

if exists(global.minProbeX)
	if global.minProbeX < (sensors.probes[0].offsets[0] + var.SafeZone)
		echo "minProbeX (" ^ global.minProbeX ^ ") unreachable - reset to " ^ (sensors.probes[0].offsets[0] + var.SafeZone)
		set global.minProbeX = (sensors.probes[0].offsets[0] + var.SafeZone)
	set var.m557MinX = global.minProbeX

if exists(global.maxProbeX)
	if global.maxProbeX < (global.minProbeX + (var.MinSpace*2))
		set global.maxProbeX = (global.minProbeX + (var.MinSpace*2))
	if global.maxProbeX > (move.axes[0].max - sensors.probes[0].offsets[0] - var.SafeZone)
		echo "maxProbeX (" ^ global.maxProbeX ^ ") unreachable - reset to " ^ (move.axes[0].max - sensors.probes[0].offsets[0] - var.SafeZone)
		set global.maxProbeX = (move.axes[0].max - sensors.probes[0].offsets[0] - var.SafeZone)
	set var.m557MaxX = global.maxProbeX

if exists(global.minProbeY)
	if global.minProbeY < (sensors.probes[0].offsets[1] + var.SafeZone)
		echo "minProbeY (" ^ global.minProbeY ^ ") unreachable - reset to " ^ (sensors.probes[0].offsets[1] + var.SafeZone)
		set global.minProbeY = (sensors.probes[0].offsets[1] + var.SafeZone)
	set var.m557MinY = global.minProbeY


if exists(global.maxProbeY)
	if global.maxProbeY < (global.minProbeY + (var.MinSpace*2))
		set global.maxProbeY = (global.minProbeY + (var.MinSpace*2))
	if global.maxProbeY > (move.axes[1].max - sensors.probes[0].offsets[1] - var.SafeZone)
		echo "maxProbeY (" ^ global.maxProbeY ^ ") unreachable - reset to " ^ (move.axes[1].max - sensors.probes[0].offsets[1] - var.SafeZone)
		set global.maxProbeY = (move.axes[1].max - sensors.probes[0].offsets[1] - var.SafeZone)
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

M557 X{var.m557MinX,var.m557MaxX} Y{var.m557MinY,var.m557MaxY} P{var.ProbeNumX,var.ProbeNumY}
;echo "M557 X" ^ {var.m557MinX} ^ ":" ^ {var.m557MaxX} ^ " Y" ^ {var.m557MinY} ^ ":" ^ {var.m557MaxY} ^  " P" ^ {var.ProbeNumX} ^ ":" ^ {var.ProbeNumY}
if result != 0
	abort "ERROR: could not create mesh" 
;M557
G29 S0