;example of wipe moves between Y10 and Y6, starting at X10 and stepping across 1mm on each pass
while iterations < #move.axes
	if !move.axes[iterations].homed ; check if each axis is homed
		M291 P{"Axis " ^ move.axes[iterations].letter ^ " is not homed.  Home now?"} R"Axis un-homed" S3
		M98 P{"0:/sys/home" ^ (move.axes[iterations].letter) ^ ".g"}
		
G1 X10 F3000 Y10 Z10; move to start point

while iterations < 9
	if mod(iterations+1,2)==0 ; check if odd or even number remembering iterations starts at zero
		G1 X{10 +  iterations} F1800
		G1 Y60
	else
		G1 X{10 + iterations}
		G1 Y10