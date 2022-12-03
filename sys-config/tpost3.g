; tpost3.g
; called after tool 3 has been selected
M591 D0 S1 ; enable filament sensor
M116 P1 ; wait for temps
M98 P"0:/sys/zLimitAdjust.g" ; adjust Z minima if needed because of tool offset