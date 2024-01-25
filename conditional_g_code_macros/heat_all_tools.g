while iterations < #tools
	G10 P{iterations} R140 S205 ;set standby and active temp
	T{iterations} P0; set the tool to active to begin heating but don't run macro
M116	;wait for heating to finish
; this would leave tool 1 selected
T-1 P0; set both tools to standby
echo "finished"