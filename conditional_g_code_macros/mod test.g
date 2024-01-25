while iterations < 6
	if mod(iterations+1,2)!=0
		echo "odd number"
		M291 P{iterations+1 ^ " is an odd number"} R"Odd number" S2
	else
		echo "even number"
		M291 P{iterations+1 ^ " is an even number"}  R"Even number" S2
	G4 S0.5
if !move.axes[0].homed
	M291 P"axis is not homed (IF)" R"check" S2
elif move.axes[1].homed
	M291 P"axis 1 is homed, but not 0 (ELIF)" R"check" S2
else
	M291 P"axis is not homed (ELSE)" R"check" S2
	
