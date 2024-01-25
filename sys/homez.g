; homez.g
; called to home the Z axis
M98 P"0:/sys/checkATX.g"
M566 X200.00 Y200.00 Z10.00 E800.00                          ; set maximum instantaneous speed changes (mm/min)
M203 X1200.00 Y1200.00 Z600.00 E6000.00                  ; set maximum speeds (mm/min)
M201 X400.00 Y400.00 Z60.00 E120.00                        ; set accelerations (mm/s^2)

G91                     ; relative positioning
G1 H2 Z6 F120     ; lift Z relative to current position

M400 ; wait for moves to finish
;M913  Z80 ; set X Y Z motors to 80% of their normal current

M561 ; clear any bed transform
;M290 R0 S0 ; clear babystepping

M98 P"0:/macros/bl_touch/checkProbe.g" ; check the probe for errors etc

G90                     ; absolute positioning

; heat nozzle so that any oozed plastic will not affect homing
;if state.currentTool=-1
;	T0 P0
;M568 P{state.currentTool} R{heat.coldRetractTemperature + 10} S{heat.coldExtrudeTemperature + 10} A2
;M291 R"Heating nozzle" P"Heating nozzle to " ^ {heat.coldExtrudeTemperature + 10} S0 T3
;M116

; variabes set in Config.g
G1 X{global.Bed_Center_X - sensors.probes[0].offsets[0] } Y{global.Bed_Center_Y - sensors.probes[0].offsets[1]} F1200
M400 ; wait for moves to finish
G30               ; home Z by probing the bed
if result !=0
	abort "Print cancelled due to probe error"

M400 ; wait for moves to finish
M913 X100 Y100 Z100 ; set X Y Z motors to 100% of their normal current

;reset speeds
M98 P"0:/sys/set_max_speeds.g"

; Uncomment the following lines to lift Z after probing
;G91                ; relative positioning
;G1 H2 Z5 F100      ; lift Z relative to current position
;G90                ; absolute positioning

