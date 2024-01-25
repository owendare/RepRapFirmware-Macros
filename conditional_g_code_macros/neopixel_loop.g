; 0:/sys/daemon.g


if !exists(global.runLED)
	global runLED = true
	
if global.runLED = false ; send "set global.runDaemn = false" to stop daemon if needed
	M99 ; exit daemon.  

if !exists(global.ledSize)
	global ledSize = 12 ; modify to change delay.
if !exists(global.ledDelay)
	global ledDelay = 2 ; modify to change delay. 
if !exists(global.rLED)
	global rLED = 255 ; set red value 0 to 255
if !exists(global.gLED)
	global gLED = 0 ; set green value 0 to 255
if !exists(global.bLED)
	global bLED = 0 ; set blue value 0 to 255
if !exists(global.wLED)
	global wLED = 0 ; set red value	0 to 255
if !exists(global.ledBrightness)
	global ledBrightness = 255 ; set brightness value 0 to 255
if !exists(global.ledState)
	global ledState = 1  ; this will be toggled between 0 and 1 on each loop
	
;M150 R0 U0 B0 P0 W0 S58 F0  ; turn off neopixels before we start

while true ; create an endless loop

	if global.runLED = false
		;M150 R0 U0 B0 P0 W0 S58 F0  ; turn off neopixels
		break
		echo "exiting macro"
		M99 ; exit daemon.
	if state.status ="processing" ; check if we are printing
		;toggle the LED state at each loop
		if global.ledState = 0
			set global.ledState = 1
		else
			set global.ledState = 0
		;loop through all the LED's
		while iterations < global.ledSize - 1 ; set to 1 less than number of LED's in neopixel
			if global.runLED = false
				;M150 R0 U0 B0 P0 W0 S58 F0  ; turn off neopixels
				echo "exiting loop"
				break
			if global.ledState = 0
				echo "next LED on " , iterations
			else
				echo "Next LED off" , iterations
			;M150 R{global.rLED} U{global.gLED} B{global.bLED} W{global.wLED} P{global.ledState = 1 ? global.ledBrightness : 0} S1 F1     ; set next LED in loop to either brightness or off
			G4 S{global.ledDelay}
		;M150 R{global.rLED} U{global.gLED} B{global.bLED} W{global.wLED} P{global.ledState = 1 ? global.ledBrightness : 0} S1 F0     ; set last LED in loop
		echo "last LED"
		G4 S{global.ledDelay}
	else
		;M150 R0 U0 B0 P0 W0 S58 F0  ; turn off neopixels if we have stopped printing
		G4 S{global.ledDelay}
	G4 S{global.ledDelay}
		
if global.runLED = false
	;M150 R0 U0 B0 P0 W0 S58 F0  ; turn off neopixels
	echo "exiting macro"
	M99 ; exit daemon.
		
if state.status !="processing"
	G4 S1 ; if we aren't printing add a delay to give control back to processor