; set_LED_while_heating.g

; Parameters can be passed for Tool number and target temp
; S = target temperature 
; T = Tool number

; example in Prusa slicer start code
; ####
; M568 P[current_extruder] R{"{heat.coldExtrudeTemperature+5}"} S[first_layer_temperature_0] A2 
; M98 P"set_LED_while_heating.gcode" S[first_layer_temperature_0] T[current_extruder]
; M116
; ###

var toolNumber = 0
var targetTemp = 120

if exists(param.T)
	set vartoolNumber = param.T
if exists(param.S)
	set var.targetTemp = param.S

while heat.heaters[tools.[var.toolNumber].heaters[0]].current < var.targetTemp
    M98 P"set_led_by_temp.gcode"
    G4 S3
; done heating, so set to white

M150 R255 U255 B255 W255 P255 F0 ; set pixels