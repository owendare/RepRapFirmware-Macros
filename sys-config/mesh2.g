;mesh.g
M98 P"setDefaultProbePoints.g"
if (exists(param.A) && exists(param.B) && exists(param.C) && exists(param.D) && exists(param.N))
	M557 X{max(move.compensation.probeGrid.mins[0],param.A),min(move.compensation.probeGrid.maxs[0],param.B)} Y{max(move.compensation.probeGrid.mins[1],param.C),min(move.compensation.probeGrid.maxs[1] ,param.D)} S{param.N}
	if result != 0
		abort "Invalid M557 parameters"

G29 S0

