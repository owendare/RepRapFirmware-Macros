var SafeZone = 10
var MinReachableX = (sensors.probes[0].offsets[0] + var.SafeZone)
var MaxReachabeX = (move.axes[0].max - sensors.probes[0].offsets[0] - var.SafeZone)
var MinReachableY =  (sensors.probes[0].offsets[1] + var.SafeZone)
var MaxReachabeY = (move.axes[1].max - sensors.probes[0].offsets[1] - var.SafeZone)

M557 X{var.MinReachableX,var.MaxReachabeX} Y{var.MinReachableY,var.MaxReachabeY} S30; define mesh grid

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
