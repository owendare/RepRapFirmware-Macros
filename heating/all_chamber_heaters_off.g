M291 P"Shutting down chamber heaters" R"Heaters" S0 T1
G4 S1.1 ; wait for popup
while iterations < #heat.chamberHeaters
	;echo "checking chamber heater " ^ iterations-1
	if heat.chamberHeaters[iterations]!=-1
		M141 P{iterations} S0 R0
		M141 P{iterations} S-276
		M291 P{"Chamber # " ^ iterations ^ " off"} R"Heaters" S0 T1
echo "All chamber heaters turned off"