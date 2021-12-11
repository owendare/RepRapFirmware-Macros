while #tools > iterations
	if (tools[iterations]!=null) && (#tools[iterations].heaters >0)
		M568 P{iterations} S0 R0
		M568 P{iterations} A0 ; Set active and standby temps to zero & turn off heaters
		M291 P{"Tool " ^ (iterations) ^ " is set to " ^ heat.heaters[tools[0].heaters[0]].state} S0 T1.5
		G4 S1.6 ; wait for popup

while iterations < #heat.chamberHeaters
	if heat.chamberHeaters[iterations]!=-1
		M141 P{iterations}S0 R0 ;set chamber temp to zero
		M141 P{iterations} S-275 ; chamber heater off
		M291 P{"Chamber # " ^ iterations ^ " off"} S0 T1

while iterations < #heat.bedHeaters
	if heat.bedHeaters[iterations] !=-1
		M140 P{iterations} S0 R0 ; make bed temp zero
		M140 P{iterations} S-275 ; bed off
		M291 P{"Bed # " ^ iterations ^ " off"} S0 T1
		G4 S1.1 ; wait for popup