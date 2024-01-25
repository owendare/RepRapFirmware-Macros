var count = 0
var mainLoop = 2
var subLoop = 4
var choices = null
M291 S4 R"Choose type" P"Choose which message box type" K{"1","2","3","4","5","6","7"} F0
var sType = input + 1
if var.sType = 4
	set var.choices = vector(var.subLoop,null)
	while iterations < var.subLoop
		set var.choices[iterations] = "Choice " ^ iterations

while iterations < 1
	echo "Count = " ^ iterations
	set var.count = iterations
	while iterations < 4
		echo "Sub run = " ^ iterations
		if var.sType = 1
			M291 R{"Main count = " ^ var.count} P{"Sub run = " ^ iterations} S1 T4;
			G4 S3
		if var.sType = 2
			M291 R{"Main count = " ^ var.count} P{"Sub run = " ^ iterations} S2; does not resume operation when OK closed unless M292 sent from console. M99 aborts the macro but leaves the message box in play
		if var.sType = 3
			M291 R{"Main count = " ^ var.count} P{"Sub run = " ^ iterations} S3 ; works as expected except that if previous macro used S2 and M99 was used without M292, the first iteration doesn't show and M292 is required.
		if var.sType = 4
			M291 R{"Main count = " ^ var.count} P{"Sub run = " ^ iterations} S4 K{var.choices} F{iterations}  ; works as expected
		
		if var.sType = 5
			M291 R{"Main count = " ^ var.count} P{"Sub run = " ^ iterations} S5 H10 L0 F5 ; operates as normal
		
		if var.sType = 6
			M291 R{"Main count = " ^ var.count} P{"Sub run = " ^ iterations} S6 H{iterations} L0 F{iterations} ; This will stop messagebox after var.count > 1, but doesn't stop macro
		if var.sType = 7
			M291 R{"Main count = " ^ var.count} P{"Sub run = " ^ iterations} S7 H30 L0 F{"Run " ^ iterations} ; seems to operate normally
		;M291 R{"Main count = " ^ var.count} P{"Sub run = " ^ iterations} S7 H{pi} L0 F{var.count} ; passed float to H param. Gives error in console, message box doesn't display, but macro continues.
		;echo input 
		G4 P200
		echo "window closed " ^ var.count ^ " : " ^ iterations ^ " input = " ^ input ; this won't display unless you send M292 if M291 S2 used even after OK pressed
		;echo "window closed " ^ var.Count ^ " : " ^ iterations ; this line has a deliberate error macro will be stopped.
		G4 S1
