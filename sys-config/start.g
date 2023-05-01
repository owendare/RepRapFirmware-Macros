;start.g - Run at the start of each print
M118 S"Running start.g"
if (state.atxPower!=true)
	M80 ; turn on power to motors & heaters
	G4 S3 ; wait a few seconds to let power stabilise
G4 S0.5 ; wait 1/2 second
set global.Cancelled = false
set global.InMacro = false
if sensors.filamentMonitors[0].status="ok"
	set global.filamentDistance = 0 ; reset filament sensor extrusion distance after tripping
else
	abort "Filament sensor shows no filament loaded.  Print aborted"

;check if we want to start immediately of after a delay
; Date-Time format must be - 2022-04-01T06:00:00
var hours = 0
var minutes = 0
var startTime = state.time
var timeCheck= state.time 
var delayedStart = false
M291 P"Start after delay?" R"Delay?" S4 K{"Yes","No"}
if input = 0
	set var.delayedStart = true
	; start of code to use hours and minutes from now.
	;M291 S6 P"Input number of hours till start" L0 H24 F0
	;set var.hours = input
	;M291 S6 P"Input number of minute till start" L0 H59 F0
	;set var.minutes = input
	;M98 P"0:/macros/print/start_after_delay.g" H{var.hours} S{var.minutes}
	; end of code to use hours and minutes from now.

	; start of code to use Specific date and time to start.
	set var.startTime=state.time
	M291 S4 P"Choose method to set time" R"Select method" K{"Add hours/minutes from now","Specify time",} F0
	if input = 1
		M291 S7 P{"Enter start date time (Default 1 hour from now). Format = " ^ var.startTime} L19 H19 F{var.startTime + 3600}
		set var.timeCheck = datetime(input) ; if the format is wrong this will cause an error which cancels the macro & print
		M118 P0 L1 S{"Start time selected is " ^ input}
	else
		var hoursFromNow = 0
		var minsFromNow = 0
		M291 S5 P"Enter hours from now to start (0-24)" L0 H24 F0
		set var.hoursFromNow = input
		M291 S5 P"Enter minutes to add till start (0-59)" R{"Hours to start = " ^ var.hoursFromNow} L0 H59 F0 
		set var.minsFromNow = input
		set var.timeCheck = datetime(var.startTime + (var.hoursFromNow*3600) + (var.minsFromNow*60))
		M118 P0 L1 S{"Start time selected is " ^ var.timeCheck}
	G4 P100
	
	if var.timeCheck <= state.time
		M118 P0 L1 S{"ERROR: Start time entered is before current time.  Print cancelled"}
		G4 S2
		echo >"0:/sys/print_log.txt" "Delayed start was cancelled.  Start time less than current time"
		G4 S1
		abort "ERROR: Start time entered is before current time"
	echo >"0:/sys/print_log.txt" "Delayed start. Print will be started at", var.timeCheck
	M98 P"0:/macros/print/start_after_delay.g" R{var.timeCheck}
	; end of code to use Specific date and time to start.



M42 P5 S1; turn on LED strip driven by P5 output
if {state.gpOut[5].pwm==1} ; check if output activated and report
	M118 S"LED strip is on"
else
	M118 S"LED strip output did not activate"
if !(sensors.filamentMonitors[0].status="ok")
	abort "No filament detected by sensor - print cancelled"
	
M98 P"0:/sys/setDefaultProbePoints.g" ; reset probe points
M98 P"0:/sys/set_max_speeds.g" ; reset max speeds
M913 X100 Y100 Z100 ; set X Y Z motors to 100% of their normal current
if var.delayedStart = false
	echo >"0:/sys/print_log.txt" "Print started at", state.time
	G4 P100
echo >>"0:/sys/print_log.txt" job.file.fileName
echo >>"0:/sys/print_log.txt" "***************"
M118 S"exiting start.g"