;setTemp.g
;sets temps based on filament name passed as "S" parameter
;e.g. M98 P"0:/macros/setTemps.g S"ABS"
if state.currentTool = -1
	abort "No tool elected - can't set temp" ; cancel macro and print
if !exists(param.S) || param.S = "" || param.S = null
	echo "No S parameter passed to macro - default temps used"
	G10 S200 R125
	M99 ; exit macro
if param.S = "ABS"
	G10 S240 R180
elif param.S = "PLA"
	G10 S205 R125
elif param.S = "PETG"
	G10 S240 R180
elif param.S = "NYLON"
	G10 S255 R180
else
	echo param.S ^ "not defined in macro - default temp set"
	G10 S200 R125
