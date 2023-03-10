;mesh.g
M98 P"setDefaultProbePoints.g"
M561 ; clear any bed transform
if (exists(param.A) && exists(param.B) && exists(param.C) && exists(param.D) && exists(param.N))
	var xDistance = (param.B - param.A)
	var yDistance = (param.D - param.C)
	var smallestRequired = min(var.xDistance,var.yDistance)
	var probeDistance = floor(min(var.smallestRequired,param.N))
	echo "Probe distance used:", var.probeDistance,"mm"
	var xMin = max(move.compensation.probeGrid.mins[0],param.A)
	echo "xMin =", max(move.compensation.probeGrid.mins[0],param.A)
	var xMax = min(move.compensation.probeGrid.maxs[0],param.B)
	echo "xMax =", min(move.compensation.probeGrid.maxs[0],param.B)
	var yMin = max(move.compensation.probeGrid.mins[1],param.C)
	echo "yMin =", max(move.compensation.probeGrid.mins[1],param.C)
	var yMax = min(move.compensation.probeGrid.maxs[1] ,param.D)
	echo "yMax =", min(move.compensation.probeGrid.maxs[1] ,param.D)
	M557 X{var.xMin,var.xMax} Y{var.yMin,var.yMax} S{var.probeDistance}
	if result != 0
		echo "Points used X",var.xMin,":",var.xMax,"Y",var.yMin,":",var.yMax, " Spacing:", var.probeDistance
		abort "Invalid M557 parameters"
var ProbeCenterX = (move.compensation.probeGrid.maxs[0] - ((move.compensation.probeGrid.maxs[0] - move.compensation.probeGrid.mins[0])/2)) ; calculate centre point of probe area
var ProbeCenterY = (move.compensation.probeGrid.maxs[1] - ((move.compensation.probeGrid.maxs[1] - move.compensation.probeGrid.mins[1])/2)) ; calculate centre point of probe area
echo "Establishing Z0 at point X" ^ var.ProbeCenterX ^ " : Y" ^ var.ProbeCenterY
G1 X{var.ProbeCenterX - sensors.probes[0].offsets[0]} Y{var.ProbeCenterY - sensors.probes[0].offsets[1]} Z{sensors.probes[0].diveHeight+2} F3600
G30
if result !=0
	abort "Error during probing - print cancelled"
G29 S0
if result = 2
	abort "Error during mesh probing - print cancelled"
;var ProbeCenterX = (move.compensation.probeGrid.maxs[0] - ((move.compensation.probeGrid.maxs[0] - move.compensation.probeGrid.mins[0])/2)) ; calculate centre point of probe area
;var ProbeCenterY = (move.compensation.probeGrid.maxs[1] - ((move.compensation.probeGrid.maxs[1] - move.compensation.probeGrid.mins[1])/2)) ; calculate centre point of probe area
G1 X{var.ProbeCenterX - sensors.probes[0].offsets[0]} Y{var.ProbeCenterY - sensors.probes[0].offsets[1]} Z{sensors.probes[0].diveHeight+2} F3600
G30
if result !=0
	abort "Error during probing - print cancelled"