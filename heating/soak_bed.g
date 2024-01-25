; soak_bed.g
var defaultValue = 6 ; as fixed degrees if bed set to 50 degrees or less
var targetPercentage = 12 ; as percentage of active bed temp if over 50 degrees

if heat.heaters[0].state = "off"
	echo "Bed heater is off.  Nothing to do"
	M99 ; exit macro as no need to soak
var target = 5	
; By default until both bed sensors are +/ 4 degrees before continuing
; target can be passed by parameter and must be less than 10% of bed target temperature
if heat.heaters[0].active <= 50
	set var.target = var.defaultValue
else
	set var.target = max(var.defaultValue,ceil(heat.heaters[0].active*(var.targetPercentage/100)))
	
echo "soak target is " ^ var.target	^ " degrees"

set global.BedHasSoaked = false 

if exists(param.S) ; if the target is passed by parameter we'll use it
	if (param.S > 0) && (param.S < 20) && (param.S <= heat.heaters[0].active/10)
		var.target = param.S
	else
		abort "Invalid soak target value passed to macro: soak_bed.g"

echo "Bed is " ^ heat.heaters[0].current ^ "   :    Edge temp is " ^ sensors.analog[8].lastReading
while  ((heat.heaters[0].active - var.target) > (sensors.analog[8].lastReading)) && (global.BedHasSoaked = false)
	if heat.heaters[0].state != "active"
		echo "Bed heater no longer active.  Soaking cancelled"
		M99 	
	M291 R{"Soaking Bed (" ^ heat.heaters[0].active ^ "C)  Please wait"} P{"Bed temp = " ^  heat.heaters[0].current ^ " : Edge temp = " ^ (sensors.analog[8].lastReading)}  S0 T2
	G4 S4
	if global.Cancelled = true
		M108
		M98 P"0:/macros/heating/all_heaters_off.g"
		abort "heating cancelled"
echo {global.BedHasSoaked=false ? "Bed soaking complete" : "Bed soaking cancelled or inactive"}
set global.BedHasSoaked = true
