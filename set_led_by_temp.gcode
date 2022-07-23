; set_led_by_temp.gcode

; This macro sets neopixels based on tool heater temp
; It should be called from daemon.g to achieve continual updates
; LED strip pixel count must equal number of tools * pixels per tool 
; For multiple tools the neopixels must be daisy chained or a continuos strip

; define the LED (probably should be in config.g)
M150 X1 Q3000000      ; set LED type to NeoPixel and set SPI frequency to 3MHz


; adjust these variable temps to suit.   Anything uder lowHeat will generate cold temp values
var lowHeat = 50
var medHeat = 130
var highHeat = 180

; brightness will be scaled between lowBrightness and highBrightness according to how close it is the max for range
var lowBrightness = 100
var highBrightness = 255

; mumber of pixels on the strip that are assigned to each tool e.g first five are tool 1, second 5 are tool 2 etc
var pixelsPerTool = 5 

;adjust values following to achieve desired colors for each range
; this will be so much easier when we have arrays ;-)

; high temp values
var highRed = 255
var highGreen = 0
var highBlue = 0

;medium temp values
var midRed = 255
var midGreen = 128
var midBlue = 0

;low temp values
var lowRed = 0
var lowGreen = 255
var lowBlue = 0

; cold temp values
var coldRed = 0
var coldGreen = 0
var coldBlue = 255

; #############################  SHOULD NOT NEED TO EDIT PAST HERE   ################################

; create other needed variables
var thisHeater= 0
var thisHeaterTemp = 0
var upperTemp = 0
var thisTool= 0
var F=0
var maxTemp = 0 
var scale = 0
var redValue = 0
var greenValue = 0
var blueValue = 0
var setBrightness = 0

; sanity checks
if (var.lowBrightness < 0) || (var.highBrightness > 255) || (var.highBrightness < var.lowBrightness)
	echo "Invalid brightness settings.  Must be between 0 & 255.  High must be > than low.  Setting to defaults (Low 100, high 255)"
	set var.lowBrightness = 100
	set var.highBrightness = 255
if (var.lowHeat <= 0) || (var.medHeat <= var.lowHeat) || (var.highHeat <= var.medHeat)
	echo "Invalid temp range setings - resetting to defaults (low=50, medium=130,high=180)"
	set var.lowHeat = 50
	set var.medHeat = 130
	set var.highHeat = 180
	
; gather the tool temperatures
while iterations < #tools ; loop through the tools
	set var.thisTool = iterations
	set var.upperTemp = 0 ; reset the upper temp
	set var.maxTemp = 0 ; reset the max temp
	while iterations < #tools[var.thisTool].heaters ; loop through the heaters on each tool and get max temp
		set var.thisHeater = tools[var.thisTool].heaters[iterations]
		set var.thisHeaterTemp = heat.heaters[var.thisHeater].current
		if var.thisHeaterTemp > var.upperTemp
			set var.upperTemp = var.thisHeaterTemp
			set var.maxTemp = heat.heaters[var.thisHeater].max
			
	; determine if there will be more commands in this loop
	if iterations = #tools - 1
		set var.F = 0
	else
		set var.F = 1	
		
	; Set the group of LEDs based on the temperature
	if var.upperTemp >= var.highHeat
		set var.scale = (var.highBrightness - var.lowBrightness) / (var.maxTemp - var.highHeat)
		set var.setBrightness = floor((var.scale * (var.thisHeaterTemp - var.highHeat)) + 0.5) + var.lowBrightness ;
		set var.redValue = var.highRed
		set var.blueValue = var.highBlue
		set var.greenValue = var.highGreen
		;echo "Tool ", iterations , "set to red (High)" 
	elif var.upperTemp >= var.medHeat
		set var.scale = (var.highBrightness - var.lowBrightness) / (var.highHeat - var.medHeat)
		set var.setBrightness = floor(var.scale * (var.thisHeaterTemp -  var.medHeat) + 0.5) + var.lowBrightness ;
		set var.redValue = var.midRed
		set var.blueValue = var.midBlue
		set var.greenValue = var.midGreen
		;echo "Tool ", iterations , "set to orange (Med)"
	elif var.upperTemp >= var.lowHeat
		set var.scale = (var.highBrightness - var.lowBrightness) / (var.medHeat - var.lowHeat)
		set var.setBrightness = floor(var.scale * (var.thisHeaterTemp -  var.lowHeat) + 0.5) + var.lowBrightness ;
		set var.redValue = var.lowRed
		set var.blueValue = var.lowBlue
		set var.greenValue = var.lowGreen
		;echo "Tool ", iterations , "set to green (Low) "	
	else
		set var.scale =   (var.highBrightness - var.lowBrightness) /(var.lowHeat - 0)
		set var.setBrightness = floor(var.scale * (var.thisHeaterTemp - 0) + 0.5) + var.lowBrightness ;
		set var.redValue = var.coldRed
		set var.blueValue = var.coldBlue
		set var.greenValue = var.coldGreen
		;echo "Tool ", iterations , "set to blue (Cold)"
	;echo "Brightness set to ", var.setBrightness , "Colour values", var.redValue, var.greenValue, var.blueValue	
	
	;set the pixels	& brightness
	M150 R{var.redValue} U{var.greenValue} B{var.blueValue} {var.setBrightness} S{var.pixelsPerTool} F{var.F} ; set pixels
	
