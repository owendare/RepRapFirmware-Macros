;setDefaultProbePoints.g - to be called from config.g after Z probe configuration section and any time defaults need to be reset.

var SafeZone = 10 ; probing won't be done closer than this amount from bed edge - adjust as required
var defaultProbeSpacing = 50 ; default mesh grid spacing in mm - adjust as required

; shouldn't need to edit after here
var MinReachableX = max(0,sensors.probes[0].offsets[0]) + var.SafeZone
var MaxReachabeX = move.axes[0].max - abs(sensors.probes[0].offsets[0]) - var.SafeZone
var MinReachableY =  max(0,sensors.probes[0].offsets[1]) + var.SafeZone
var MaxReachabeY = move.axes[1].max - abs(sensors.probes[0].offsets[1]) - var.SafeZone

M557 X{var.MinReachableX,var.MaxReachabeX} Y{var.MinReachableY,var.MaxReachabeY} S{var.defaultProbeSpacing}; define mesh grid
echo "M557 X"^{var.MinReachableX}^","^{var.MaxReachabeX}, "Y"^{var.MinReachableY}^","^{var.MaxReachabeY}, "S"^{var.defaultProbeSpacing}
if !exists(global.minProbeX)
	global minProbeX = move.compensation.probeGrid.mins[0]
else
	set global.minProbeX = move.compensation.probeGrid.mins[0]

if !exists(global.minProbeY)
	global minProbeY = move.compensation.probeGrid.mins[1]
else
	set global.minProbeY = move.compensation.probeGrid.mins[1]

if !exists(global.maxProbeX)
	global maxProbeX = move.compensation.probeGrid.maxs[0]
else
	set global.maxProbeX = move.compensation.probeGrid.maxs[0]

if !exists(global.maxProbeY)
	global maxProbeY = move.compensation.probeGrid.maxs[1]
else
	set global.maxProbeX = move.compensation.probeGrid.maxs[1]
