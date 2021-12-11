; Probe the same spot 10 times to test repeatably.

M291 P"Probe will be tested 10 times and return mean and standard deviation. Ok or Cancel?" R"Begin probe test?" S3 ; User must click OK or cancel.

; Check if any axis hasn't been homed, and home it if required
while iterations < #move.axes ; By putting # in front of the array object, it will return the number of configured axis
	if !move.axes[iterations].homed ; if this axis is not homed
	G28 ; home all axes
	break ; no need to continue this loop
else
	; All axes are homed, but may not be in a point that can be probed. Move to the center of the area that can be probed.
	G1 X{(move.compensation.probeGrid.xMax - move.compensation.probeGrid.xMin)/2} Y{(move.compensation.probeGrid.yMax - move.compensation.probeGrid.yMin)/2} Z15 F6000

;now begin our probe test
while iterations < 10
	if iterations <9
		G30 P{iterations} X{move.axes[0].machinePosition} Y{move.axes[1].machinePosition} Z-9999 ; probe the current position and record the offset
	else
		G30 P{iterations} X{move.axes[0].machinePosition} Y{move.axes[1].machinePosition} Z-9999 S-1 ; probe the current position and calculate the deviation