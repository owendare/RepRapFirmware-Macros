while true
	if iterations = 5
		abort "maximum reached"
	var text = "Loop" ^ iterations
	M291 R{var.text} P"Press OK to begin" S3
	while true
		if iterations = 10
			break
		var thisText = "Iteration = " ^ {iterations + 1}
		M291 R"Counting" P{var.thisText} S0
		G4 P500
		M292 P0