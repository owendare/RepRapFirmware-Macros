; set_led_by_temp.gcode

; This macro sets neopixels based on tool heater temp
; It should be called from daemon.g to achieve continual updates
; or by another macro with a loop if you only want to change colours during heatup

;example macro called from your slicer start code before after temps, but before M116
; #####
;while heat.heaters[1].current < 120
;    M98 P"set_led_by_temp.gcode"
;    G4 S3
; done heating, so set to white
;M150 R255 U255 B255 W255 P255 F0 ; set pixels
; #######

; LED strip pixel count must equal number of tools * pixels per tool 
; For multiple tools the neopixels must be daisy chained or a continuos strip
; The colour will gradually scale from one to the next.

; define the LED (should be in config.g as the value is remembered between calls)
;M150 X2 Q3000000      ; set LED type to NeoPixel bit banged type and set SPI frequency to 3MHz

var RGBW = false  ; set to true if LED is RGBW type, oherwise set to false

var logging = true ; set to true if you want echos to appear in console to help see what the values are.  Otherwise set false

; adjust these variable temps to suit requirements.
var lowTemp = 30
var medTemp = 70
var highTemp = 120

; brightness will be scaled between lowBrightness and highBrightness according to how close it is the max for range
; eg. between low temp and med temp
; once over high temp it will scale between high temp and max heater temp as set in config.g
; to not scale brightness, set both values the same
var lowBrightness = 100
var highBrightness = 255

; number of pixels on the strip that are assigned to each tool e.g first five are tool 1, second 5 are tool 2 etc
; if only one tool is used, set to total number of led's on strip
var pixelsPerTool = 5 

; Common RGB colours (R,G,B)
; RED -		255,0,0
; YELLOW -	255,255,0
; ORANGE -	255,165,0
; BLUE -	0,0,255
; LIME -	0,255,0
; GREEN -	0,128,0
; MAGENTA - 255,0,255
; WHITE -	255,255,255
; OFF -		0,0,0


;adjust values following to achieve desired colors for each range
; this will be so much easier when we have arrays ;-)
; all values must be integers between 0 & 255

; high temp values (anything over high temp  will be set to this)
var highRed = 255
var highGreen = 12
var highBlue = 40
var highWhite = 0 ; only used on RGBW type

;medium temp values
var midRed = 200
var midGreen = 128
var midBlue = 20
var midWhite = 40 ; only used on RGBW type

;low temp values
var lowRed = 0
var lowGreen = 255
var lowBlue = 0
var lowWhite = 60 ; only used on RGBW type

; cold temp values (anything under low temp will be set to this)
var coldRed = 0
var coldGreen = 0
var coldBlue = 255
var coldWhite = 0 ; only used on RGBW type



; #############################  SHOULD NOT NEED TO EDIT PAST HERE   ################################

; create other needed variables
var thisHeater= 0
var thisHeaterTemp = 0
var upperTemp = 0
var thisTool= 0
var F=0
var maxTemp = 0 
var brightScale = 0
var redValue = 0
var greenValue = 0
var blueValue = 0
var whiteValue = 0
var setBrightness = 0
var redScale= 0
var greenScale = 0
var blueScale = 0
var whiteScale = 0 
var lowValue = 0
var highValue = 0

; sanity checks
if (var.lowBrightness < 0) || (var.highBrightness > 255) || (var.highBrightness < var.lowBrightness)
	echo "Invalid brightness settings.  Must be between 0 & 255.  High must be > than low.  Setting to defaults (Low 100, high 255)"
	set var.lowBrightness = 100
	set var.highBrightness = 255
if (var.lowTemp <= 0) || (var.medTemp <= var.lowTemp) || (var.highTemp <= var.medTemp)
	echo "Invalid temp range setings - resetting to defaults (low=50, medium=130,high=180)"
	set var.lowTemp = 50
	set var.medTemp = 130
	set var.highTemp = 180
if (var.logging != true) && (var.logging != false)
	echo "Invalid logging value- must be true or false"
	set var.logging = false
	
; gather the tool temperatures
while iterations < #tools ; loop through the tools
	set var.thisTool = iterations
	set var.upperTemp = 0 ; reset the upper temp
	set var.maxTemp = 0 ; reset the max temp
	set var.lowValue = 0
	set var.highValue = 0
	while iterations < #tools[var.thisTool].heaters ; loop through the heaters on each tool and get max temp
		if var.logging = true
			echo "Checking tool", var.thisTool, "heater", iterations
		set var.thisHeater = tools[var.thisTool].heaters[iterations]
		set var.thisHeaterTemp = heat.heaters[var.thisHeater].current
		if var.logging = true
			echo "Heater", iterations, ". Temp =", var.thisHeaterTemp
		if var.thisHeaterTemp > var.upperTemp
			set var.upperTemp = var.thisHeaterTemp
			set var.maxTemp = heat.heaters[var.thisHeater].max
	if var.logging = true
		echo "Max temp of heaters is" , var.upperTemp		
	; determine if there will be more commands in this loop
	if iterations = #tools - 1
		set var.F = 0
	else
		set var.F = 1	
		
	; Set the group of LEDs based on the temperature
	
	; high temp range so just set to high temp colour values, bt scale brightness up to max heater temp
	if var.upperTemp >= var.highTemp
		set var.brightScale = (var.highBrightness - var.lowBrightness) / (var.maxTemp - var.highTemp)
		set var.setBrightness = floor((var.brightScale * (var.thisHeaterTemp - var.highTemp)) + 0.5) + var.lowBrightness ;
		set var.redValue = var.highRed ;
		set var.blueValue = var.highBlue
		set var.greenValue = var.highGreen
		set var.whiteValue = var.highWhite
		if var.logging = true
			echo "Temp is > ", var.highTemp
			echo "RGB(W) values set to -" , var.redValue, var.greenValue, var.blueValue, var.whiteValue
			echo "Brightness set to", var.setBrightness
		
		; medium range - colours will be scaled between lowtemp and medium tempas will brightness
	elif var.upperTemp >= var.medTemp
		set var.brightScale = (var.highBrightness - var.lowBrightness) / (var.highTemp - var.medTemp)
		set var.setBrightness = floor(var.brightScale * (var.thisHeaterTemp -  var.medTemp) + 0.5) + var.lowBrightness ;

		set var.lowValue = min(var.highRed,var.midRed)
		set var.highValue = max(var.highRed,var.midRed)
		set var.redScale = (var.highValue - var.lowValue) / (var.highTemp - var.medTemp)

		set var.lowValue = min(var.highGreen,var.midGreen)
		set var.highValue = max(var.highGreen,var.midGreen)		
		set var.greenScale = (var.highValue - var.lowValue) / (var.highTemp - var.medTemp)

		set var.lowValue = min(var.highBlue,var.midBlue)
		set var.highValue = max(var.highBlue,var.midBlue)		
		set var.blueScale = (var.highValue - var.lowValue) / (var.highTemp - var.medTemp)

		set var.lowValue = min(var.highWhite,var.midWhite)
		set var.highValue = max(var.highWhite,var.midWhite)		
		set var.whiteScale = (var.highValue - var.lowValue) / (var.highTemp - var.medTemp)
				
		if var.midRed < var.highRed
			set var.redValue = floor((var.redScale * (var.thisHeaterTemp - var.medTemp)) + 0.5) + var.midRed
		else
			set var.redValue = var.midRed - floor((var.redScale * (var.thisHeaterTemp - var.medTemp)) + 0.5) 
		if var.midGreen < var.highGreen
			set var.greenValue = floor((var.greenScale * (var.thisHeaterTemp - var.medTemp)) + 0.5) + var.midGreen
		else
			set var.greenValue = var.midGreen -  floor((var.greenScale * (var.thisHeaterTemp - var.medTemp)) + 0.5)
		if var.midBlue < var.highBlue
			set var.blueValue = floor((var.blueScale * (var.thisHeaterTemp - var.medTemp)) + 0.5) + var.midBlue
		else
			set var.blueValue = var.midBlue - floor((var.blueScale * (var.thisHeaterTemp - var.medTemp)) + 0.5)
		if var.midWhite < var.highWhite
			set var.whiteValue = floor((var.whiteScale * (var.thisHeaterTemp - var.medTemp)) + 0.5) + var.midWhite
		else
			set var.whiteValue = var.midWhite - floor((var.blueScale * (var.thisHeaterTemp - var.medTemp)) + 0.5)
		
		if var.logging = true
			echo "Temp is > ", var.medTemp, "but < ", var.highTemp
			echo "RGB(W) values set to -" , var.redValue, var.greenValue, var.blueValue, var.whiteValue
			echo "Brightness set to", var.setBrightness
		
		; low temp range - colours will be scaled between cold tempand medium temp range, as will brightness
	elif var.upperTemp >= var.lowTemp
		set var.brightScale = (var.highBrightness - var.lowBrightness) / (var.medTemp - var.lowTemp)
		set var.setBrightness = floor(var.brightScale * (var.thisHeaterTemp -  var.lowTemp) + 0.5) + var.lowBrightness ;

		set var.lowValue = min(var.midRed,var.lowRed)
		set var.highValue = max(var.midRed,var.lowRed)
		set var.redScale = (var.highValue - var.lowValue) / (var.medTemp - var.lowTemp)

		set var.lowValue = min(var.midGreen,var.lowGreen)
		set var.highValue = max(var.midGreen,var.lowGreen)		
		set var.greenScale = (var.highValue - var.lowValue) / (var.medTemp - var.lowTemp)
		
		set var.lowValue = min(var.midBlue,var.lowBlue)
		set var.highValue = max(var.midBlue,var.lowBlue)		
		set var.blueScale = (var.highValue - var.lowValue) / (var.medTemp - var.lowTemp)
		
		set var.lowValue = min(var.midWhite,var.lowWhite)
		set var.highValue = max(var.midWhite,var.lowWhite)		
		set var.whiteScale = (var.highValue - var.lowValue) / (var.medTemp - var.lowTemp)
		
		if var.lowRed < var.midRed
			set var.redValue = floor((var.redScale * (var.thisHeaterTemp - var.lowTemp)) + 0.5) + var.lowRed
		else
			set var.redValue = var.lowRed - floor((var.redScale * (var.thisHeaterTemp - var.lowTemp)) + 0.5)
			
		if var.lowGreen < var.midGreen
			set var.greenValue = floor((var.greenScale * (var.thisHeaterTemp - var.lowTemp)) + 0.5) + var.lowGreen
		else
			set var.greenValue = var.lowGreen - floor((var.greenScale * (var.thisHeaterTemp - var.lowTemp)) + 0.5)
			
		if var.lowBlue < var.midBlue
			set var.blueValue = floor((var.blueScale * (var.thisHeaterTemp - var.lowTemp)) + 0.5) + var.lowBlue
		else
			set var.blueValue = var.lowBlue - floor((var.blueScale * (var.thisHeaterTemp - var.lowTemp)) + 0.5)

		if var.lowWhite < var.midWhite
			set var.whiteValue = floor((var.whiteScale * (var.thisHeaterTemp - var.lowTemp)) + 0.5) + var.lowWhite
		else
			set var.whiteValue = var.lowWhite - floor((var.whiteScale * (var.thisHeaterTemp - var.lowTemp)) + 0.5)

		
		if var.logging = true
			echo "Temp is > ", var.lowTemp, "but < ", var.medTemp
			echo "RGB(W) values set to -" , var.redValue, var.greenValue, var.blueValue, var.whiteValue
			echo "Brightness set to", var.setBrightness
						
	; cold temp range, so just set colour to cold value but scale brightness between zero and low temp value
	else
		set var.brightScale =   (var.highBrightness - var.lowBrightness) /(var.lowTemp - 0)
		set var.setBrightness = floor(var.brightScale * (var.thisHeaterTemp - 0) + 0.5) + var.lowBrightness ;
		set var.redValue = var.coldRed
		set var.greenValue = var.coldGreen
		set var.blueValue = var.coldBlue
		set var.whiteValue = var.coldWhite
		if var.logging = true
			echo "Temp is < ", var.lowTemp
			echo "RGB(W) values set to -" , var.redValue, var.greenValue, var.blueValue, var.whiteValue
			echo "Brightness set to", var.setBrightness
	
	; finally, set the LED strip to the desired colour and brightness
	if var.RGBW = true
		M150 R{var.redValue} U{var.greenValue} B{var.blueValue} W{var.whiteValue} P{var.setBrightness} S{var.pixelsPerTool} F{var.F} ; set pixels
	else
		M150 R{var.redValue} U{var.greenValue} B{var.blueValue} P{var.setBrightness} S{var.pixelsPerTool} F{var.F} ; set pixels
