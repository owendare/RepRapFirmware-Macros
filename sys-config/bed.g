; bed.g
; called to perform automatic bed compensation via G32
; requires two independent Z lead screw motors to be configured
; https://duet3d.dozuki.com/Wiki/Bed_levelling_using_multiple_independent_Z_motors
; uses conditional G Code for portability (requires Reprap Firmware version 3 or higher)
; Z Mesh probe area must be properly defined in M557 https://duet3d.dozuki.com/Wiki/Gcode#Section_M557_Set_Z_probe_point_or_define_probing_grid
; Note: The maximum amount of correction possible is defined in M671 (S parameter) https://duet3d.dozuki.com/Wiki/Gcode#Section_M671_Define_positions_of_Z_leadscrews_or_bed_levelling_screws

var minDeviation = 0.018 ; Set the minimum acceptable devation

M98 P"0:/sys/checkATX.g"
M98 P"0:/sys/set_max_speeds.g" ; reset max speeds
G29 S2 ; turn off bed mesh levelling
M561 ; clear any bed transform
M290 R0 S0 ; clear babystepping

if !move.axes[2].homed  ; if Z isn't homed we need to lift it, otherwise go to the dive height + 5mm
	M564 S0 H0 ; allow movement before homing
	G91
	G1 Z15 ; raise head 15mm
	G90
	M564 S1 H1 ; dissallow movement without homing
else
	G1 Z{sensors.probes[0].diveHeight + 5} F{sensors.probes[0].speeds[0]}

;check BL Touch
if sensors.probes[0].value[0]=1000 ; if probe is in error state
	echo "Probe in error state- resetting"
	M280 P0 S160 ; reset BL Touch
	G4 S0.5
if state.gpOut[0].pwm=0.03
	echo "Probe ia already deployed - retracting"
	M280 P0 S80 ; retract BLTouch
	G4 S0.5

if sensors.endstops[2].triggered
	echo "Probe ia already triggered - resetting"
	M280 P0 S160 ; reset BL Touch
	G4 S0.5

;check state of heaters
var bedState = heat.heaters[0].state
var bedActiveTemp = heat.heaters[0].active
var bedStandbyTemp = heat.heaters[0].standby
var nozzleState = heat.heaters[1].state
M140 P0 S-276 ; turn off bed heater
M568 P0 A0 ; turn off nozzle heater

; If the printer hasn't been homed, home it
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
	G28
	if result != 0
		abort "Print cancelled due to homing error"
	
G1 F6000 ; set X/Y speed

; Probe the bed and do auto leveling
while true
  if iterations = 5
    abort "Too many auto calibration attempts"
  ;probe at XMin mesh probe point and midway of Y mesh area 
  ;use the following when variables enabled
  G30 P0 X{0 +  sensors.probes[0].offsets[0]} Y{global.Bed_Center_Y +  sensors.probes[0].offsets[1]} Z-99999

  if result != 0
    abort "Print cancelled due to probe error"
  ;probe at X Max mesh probe point and midway of Y mesh area
  G30 P1 X{move.axes[0].max} Z-99999 S2
  if result != 0
    abort "Print cancelled due to probe error"
  ;set maximum probe deviation allowed between the two points
  if (abs(move.calibration.initial.deviation) <= var.minDeviation)
    break
  ; if deviation between the two points is too high, repeat the test after Z axis has been adjusted. 
  echo "Repeating calibration because deviation is too high " ^ move.calibration.initial.deviation ^ "mm"
; end loop
G28; Home all again just to be sure
;G29 S1 ; Reload bed compensation mesh

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
