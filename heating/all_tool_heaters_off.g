; Shut down all tool heaters and set temps to zero.
M291 P"Shutting down tool heaters" R"Heaters" S0 T1
G4 S1.1 ; wait for popup
var ToolsDone = 0 ; create a variable to cope with tools that are not sequentially numbered (unlikely but possible)
while (iterations < limits.tools) && (var.ToolsDone < #tools) 
	;echo "iteration " ^ iterations
	if (tools[iterations]!=null)
		if (#tools[iterations].heaters > 0) ; check if the tool has a heater to turn off
			M568 P{iterations} S0 R0 ; Set active and standby to zero
			M568 P{iterations} A0 ; turn off heater(s) associated with this tool
			M291 P{"Tool " ^ (iterations) ^ " is set to off" } S0 T1.5 ; report heater state of tool
			G4 S1.6 ; wait for popup
		set var.ToolsDone = var.ToolsDone + 1 ; Increment the number of tools shut off.
	else
		echo "Null value Tool number - skipping #" ^ iterations
		G4 S1
		continue ; we've encountered a non sequential move to next tool number without incrementing the ToolsDone variable
echo "All tool heaters are off"