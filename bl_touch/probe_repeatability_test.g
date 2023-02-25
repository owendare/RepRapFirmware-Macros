; Probe the same spot 10 times to test repeatably.

var defaultProbeCount = sensors.probes[0].maxProbeCount

var probeSpeed = 1 ; probe speed in mm/sec

; Check if any axis hasn't been homed, and home it if required
G28 ; home all axes

G1 X{global.Bed_Center_X - sensors.probes[0].offsets[0] } Y{global.Bed_Center_Y - sensors.probes[0].offsets[1]} F12000
G30

M558 A1 T{var.probeSpeed*60*3} F{var.probeSpeed*60} ; set probe count to 1 and convert probe speed variable to mm/min

M291 P"Probe will be tested 10 times and return mean and standard deviation. Ok or Cancel?" R"Begin probe test?" S3 ; User must click OK or cancel.

echo >"0:/macros/bl_touch/repeatability_results.txt" "Begin test @ " ^ state.time
;now begin our probe test

while iterations < 10
	if iterations <9
		echo "test # " ^ iterations + 1
		G30 X{global.Bed_Center_X} Y{global.Bed_Center_Y} P{iterations}  Z-99999;  probe the current position and record the offset
		echo >>"0:/macros/bl_touch/repeatability_results.txt" "Probe test " ^ (iterations + 1) ^ " Z = " ^ sensors.probes[0].lastStopHeight ^ " deviation " ^ move.calibration.initial.deviation
	else
		echo "test # " ^ iterations + 1
		G30 X{global.Bed_Center_X} Y{global.Bed_Center_Y} P{iterations} S-1  Z-99999; probe the current position and calculate the deviation
		echo >>"0:/macros/bl_touch/repeatability_results.txt" "Probe test " ^ (iterations + 1) ^ " Z = " ^ sensors.probes[0].lastStopHeight^ " mean " ^  move.calibration.initial.deviation
		echo >>"0:/macros/bl_touch/repeatability_results.txt" "Deviation = " ^ move.calibration.initial.deviation
		echo >>"0:/macros/bl_touch/repeatability_results.txt" "Mean deviation = " ^ move.calibration.initial.mean
M558 A{var.defaultProbeCount}
echo "Test complete"
M502 ; reset parameters to config.g values
M501 ; load config-overide.g