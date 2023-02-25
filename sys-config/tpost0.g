; tpost0.g
; called after tool 0 has been selected
M591 D0 S1 ; enable filament sensor
if state.nextTool != -1
	M116 P{state.nextTool} ; wait for temps
	echo "waiting for tool", state.nextTool, "temp"
M98 P"0:/sys/zLimitAdjust.g" ; adjust Z minima if needed because of tool offset