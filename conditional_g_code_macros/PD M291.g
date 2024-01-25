var startTime=state.time
M291 S7 P{"Enter start date time (Now shown). Format = " ^ var.startTime} L19 H21 F{var.startTime + 3600}
M118 P0 L1 S{"Start time selected is " ^ input}
G4 P100
var timeCheck = datetime(input) ; if the format is wrong this will cause an error which cancels the macro & print
if var.timeCheck <= state.time
	M118 P0 L1 S{"ERROR: Start time entered is before current time.  Print cancelled"}