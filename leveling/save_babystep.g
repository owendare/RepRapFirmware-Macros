;save_babystep.g

; Add babystep to Z offset and make "persistant"

if move.axes[2].babystep !=0

	echo {"Z trigger height altered by " ^ move.axes[2].babystep ^  "mm"}

	echo {"OLD: " ^ sensors.probes[0].triggerHeight ^ " new: " ^ sensors.probes[0].triggerHeight - move.axes[2].babystep}

	G31 Z{sensors.probes[0].triggerHeight - move.axes[2].babystep}

	M500 P10:31 ; save settings to config-overide.g - Must have M501 in config.g

 

else

	echo "No babystepping set.  Nothing to save"