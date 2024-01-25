M929 P"myLog.txt" S3
if !exists(global.test1)
	global test1=40
else
	set global.test1 = 40
if !exists(global.test2)
	global test2=150
else
	set global.test2 = 150
if !exists(global.test3)
	global test3=255
else
	set global.test3 = 255
G1 X10 Y10 F3600
;M400
M106 S{global.test1}
G1 X160 Y160 F3600
;M400
M106 S{global.test2}
G1 X10 Y160 F3600
;M400
M106 S{global.test3}
G1 X90 Y90 F1800
M106 S0
M929 S0