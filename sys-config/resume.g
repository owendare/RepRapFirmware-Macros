; resume.g
; called before a print from SD card is resumed
;
; generated by RepRapFirmware Configuration Tool v2.1.4 on Sat Jan 04 2020 09:46:45 GMT+1000 (Australian Eastern Standard Time)
M98 P"0:/sys/checkATX.g"
set global.Cancelled = false
if sensors.filamentMonitors[0].status="ok"
	set global.filamentDistance = 0 ; reset filament sensor extrusion distance after tripping
M42 P5 S1; turn on LED strip driven by P5 output
T R1 ; Select last tool used
M144 S1 ; restore bed to active temp
M106 P0 R1 ; restore part cooling fan speed to what it was at pause
M116 ; Wait for temps
G1 R1 X0 Y0 Z5 F3600 ; go to 5mm above position of the last print move
G1 R1 X0 Y0          ; go back to the last print move
M83                  ; relative extruder moves
G11 		     ; unretract