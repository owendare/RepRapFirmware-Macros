while iterations < 4
	G28 X
	G1 X150 F6000
	G1 F{1000.2+iterations*2000.32}
	while iterations <2
		G1 X10
		G1 X160