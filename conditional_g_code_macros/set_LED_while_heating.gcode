; set_LED_while_heating.g

; Parameters can be passed for Tool number and target temp
; S = target temperature 
; T = Tool number
; D = delay between checks

; example in Prusa slicer start code
; ####
; M568 P[current_extruder] R{"{heat.coldExtrudeTemperature+5}"} S[first_layer_temperature_0] A2 
; M98 P"set_LED_while_heating.gcode" S[first_layer_temperature_0] T[current_extruder] D3
; M116
; ###

var toolNumber = 0
var thisTool = 0
if exists(param.T)
	set var.toolNumber = param.T
	
var targetTemp = 120
if exists(param.S)
	set var.targetTemp = param.S

var delay = 3

if exists(param.D)
	set var.delay = param.D
	
;echo "Tool number is ", var.toolNumber

if var.toolNumber != -1
	var heaterNumber = tools[var.toolNumber].heaters[0]
	while heat.heaters[var.heaterNumber].current < var.targetTemp
		M98 P"0:/macros/conditional_g_code_macros/set_led_by_temp.gcode"
		G4 S{var.delay}
else
	while iterations < #tools
		set var.thisTool = iterations 
		echo "Testing heat.heaters[tools[" , var.thisTool, "].heaters[0]]"
		if (heat.heaters[{tools[var.thisTool].heaters[0]}].state="standby")
			while (heat.heaters[{tools[var.thisTool].heaters[0]}].current) < (heat.heaters[{tools[var.thisTool].heaters[0]}].standby)
				M98 P"0:/macros/conditional_g_code_macros/set_led_by_temp.gcode"
				G4 S{var.delay}
		if (heat.heaters[tools[var.thisTool].heaters[0]].state="active")
			;echo "active"
			while (heat.heaters[tools[var.thisTool].heaters[0]].current) < (heat.heaters[tools[var.thisTool].heaters[0]].active) 
				M98 P"0:/macros/conditional_g_code_macros/set_led_by_temp.gcode"
				G4 S{var.delay}

; done heating, so set to white
M150 R255 U255 B255 W255 P255 F0 ; set pixels