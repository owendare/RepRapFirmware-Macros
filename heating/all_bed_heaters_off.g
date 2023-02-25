M291 P"Shutting down bed heaters" R"Heaters" S0 T1
G4 S1.1 ; wait for popup
while iterations < #heat.bedHeaters
	if heat.bedHeaters[iterations] !=-1
		M140 P{iterations} S0 R0
		M140 P{iterations} S-276
		M291 P{"Bed heater # " ^ iterations ^ " off"} R"Heaters" S0 T1
		G4 S1.1 ; wait for popup
echo "All bed heaters turned off"