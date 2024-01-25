if {state.gpOut[5].pwm = 1}
	echo "Pin 5 is high"
elif {state.gpOut[5].pwm = 0}
	echo "Pin 5 is low"
else
	echo {"Pin 5 value is" ^ state.gpOut[5].pwm}
G4 S1
while iterations < #state.gpOut
	if {state.gpOut[iterations]=null}
		echo {"gpOut " ^ iterations ^ " is not assigned"}
		G4 S1
	else
		echo {"gpOut " ^ iterations ^ " value is " ^ state.gpOut[iterations].pwm}
		G4 S1

while iterations < #sensors.gpIn
	if {sensors.gpIn[iterations]=null}
		echo {"gpIn " ^ iterations ^ " is not assigned"}
		G4 S1
	else
		echo {"gpIn " ^ iterations ^ " value is " ^ sensors.gpIn[iterations].value}
		G4 S1