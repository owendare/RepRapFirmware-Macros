; Pressure advance calibration macro
; first we'll set up some variables and defaults
var startX = 50 ; start position in X
var startY = 50 ; start position in Y
var xWidth = 60 ; X width of test print
var yWidth = 60 ; Y width of test print
var lowSpeed = 1800 ; low speed
var highSpeed = 3600 ; high speed
var FD = 1.75 ; filament diameter
var d= 0.4 ; nozzle diameter
var SF = 1 ; extrusion factor 0-1
var height = 0.2 ; layer height
var l = 60 ; current line length
var amount = ((var.d*var.height*var.l) + (pi*((var.height/2)*(var.height/2))*var.l)) / (pi*((var.FD/2)*(var.FD/2))) * var.SF ;; extrusion amount for next liine

if state.currentTool = -1
	abort "No tool selected"
var ThisHeater = tools[state.currentTool].heaters[0]
if {heat.heaters[var.ThisHeater].state != "active"}
	abort "Heater " ^ var.ThisHeater ^ " on " ^ tools[state.currentTool].name ^ " not active"
if  {heat.heaters[var.ThisHeater].active < heat.coldExtrudeTemperature}
	abort "Heater " ^ var.ThisHeater ^ " on " ^ tools[state.currentTool].name ^ " set below min extrude temp"
