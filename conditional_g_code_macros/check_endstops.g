;check all end stops
echo #sensors.endstops ^ " endstops found"
G4 S3; wait 3 seconds
while iterations < #sensors.endstops
	echo "endstop-" ^ iterations ^  " Type= " ^ sensors.endstops[iterations].type ^ " : state= " ^ sensors.endstops[iterations].triggered
	G4 S3; wait 3 seconds