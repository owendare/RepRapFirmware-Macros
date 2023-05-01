; start_after_delay.g
; should be called from slicer start gcode or start.g BEFORE any heating actions
; Accepts four parameters

; X = a testing parameter to allow early exit after X loops
; S = number of minutes to delay
; H = number of hours to delay
; H & S times are added to achieve total delay
; R = start time.  Must have the format R"yyyy-mm-ddThh:mm:ss" e.g R"2022-01-04T13:30:00" 
; NOTE: the use of curly braces surrounding time works in DWC but fails in SuperSlicer
; R{"2022-01-04T16:47:00"} will fail if used in SuperSlicer
; if R parameter (start time) is passed, H & S are ignored
; at least one time parameter must be passed
; e.g 
; M98 P"start_after_delay.g" H4 S20 ; (delay the start of the print for 4 hours 20 minutes) from now
; M98 P"start_after_delay.g" H1     ; (delay the start of the print for 1 hour) from now
; M98 P"start_after_delay.g" S10    ; (delay the start of the print for 10 minutes) from now
; M98 P"start_after_delay.g" R"2022-04-01T06:00:00" ; start the print on 1st April 2022 at 06:00AM

var LongDelay = 60   ; Delay between message updates if time left is greater than 1 hour
var MediumDelay = 20 ; Delay between message updates if time left is less than 1 hour but greater than 10 minutes
var ShortDelay = 10  ; Delay between message updates if time left less than 10 minutes
; at less than one minute updates will happen every 5 seconds
; at less than 10 seconds, updates will happen every second
var BeepFrequencyLow = 1000 ; frequency (low pitch) of beep play every var.ShortDelay when one minute left
var BeepFrequencyHigh = 3000 ;  frequency (high pitch) of beep play every var.ShortDelay when ten seconds left
var BeepDuration = 200 ; duration of beep in milliseconds (must be less than one second) - note 1 second will cause constant beep for last 10 seconds


; ************** Don't change below this line *****************

; Create a global variable to allow the process to be cancelled.

if !exists(global.Cancelled)
	global Cancelled = false
	
; NOTE: There will be a delay between setting this global to true and the macro/print cancelling
; as it may be called during a G4 wait commmand and can't be activated on until that finishes.
; To use, either send "set global.Cancelled = true" from the command line or a macro, or set up a button with an associated trigger.
; A separate macro may be hard to execute when the loop timer gets down to 5 or 1 seconds.

var FileName = "No file selected"

if !exists(param.X)
	if (job.file.fileName = "") || (job.file.fileName=null)
		abort "No print in progress"
	else
		set var.FileName=job.file.fileName
else
	if (job.file.fileName!=null)
		set var.FileName=job.file.fileName
;sanity check beep
if var.BeepDuration > 1000
	echo "Invalid beep duration - reset to 1/2 second)
	set var.BeepDuration = 1000
	
; sanity check default delay times
if (var.ShortDelay < 5)
	set var.ShortDelay = 5
if (var.MediumDelay < var.ShortDelay) 
	set var.MediumDelay = var.ShortDelay
if (var.LongDelay < var.MediumDelay)
	set var.LongDelay = var.MediumDelay

if !exists(param.R)
	if !exists(param.H)
		if !exists(param.S)
			echo "No parameters passed - exiting macro"
			M99
var Hours = 0 ; variable for number of whole hours from start time until run time
var Minutes = 0 ; variable for number of whole minutes from start time until run time
var Delay = 10 ; variable for delay between displaying messages
var HoursLeft= 0 ; variable for number of whole hours from current time until run time
var MinutesLeft = 0 ; variable for number of whole minutes from current time until run time
var SecondsLeft = 0 ; variable for number of whole seconds from current time until run time
var StartTime = datetime(state.time) ; variable to hold time when macro first called
var RunTime = datetime(state.time) ; variable to hold time when macro will end and print will run
var timeLeft = 0

if exists(param.R)
	set var.StartTime = datetime(param.R)
	set var.StartTime = var.StartTime - state.time
	set var.RunTime = state.time + var.StartTime
	set var.Hours = floor(var.StartTime  / 3600) ; calculate number of whole hours till start time
	set var.Minutes = floor(var.StartTime/60)-(var.Hours*60) ; calculate number of whole minutes till start time
else
	if exists(param.H)
		set var.Hours = param.H
	if exists(param.S)
		set var.Minutes = param.S
	set var.StartTime = state.time + var.Hours*60*60 + var.Minutes*60
	set var.RunTime = var.StartTime
		

var Loops = 0 ; used if a testing parameter X is passed in order to exit after number of loops has expired

echo "Print start time is " ^ var.RunTime

while state.time < var.RunTime
	if exists(global.Cancelled)
		if global.Cancelled = true 
			echo >>"0:/sys/print_log.txt" "Delayed start print cancelled at " ^ state.time
			M291 P"Operation has been cancelled" S0 T3
			G4 S3
			abort "Deferred print cancelled."
	
	if exists(param.X)
		set var.Loops = var.Loops + 1
	set var.HoursLeft = floor((var.RunTime - state.time )/60/60)
	set var.MinutesLeft = floor((var.RunTime - state.time)/60)-(var.HoursLeft*60)
	set var.SecondsLeft = mod((var.RunTime - state.time),3600)-(var.MinutesLeft*60)
	if var.RunTime - state.time > 3600
		set var.Delay = var.LongDelay
	else 
		set var.Delay = var.MediumDelay
		
	if (var.RunTime - state.time) > 600
		M291 R{var.FileName} T{var.Delay} S1 P{"Print start deferred for " ^ var.HoursLeft ^ " hrs : " ^ var.MinutesLeft ^ " mins  - " ^ var.RunTime}
		G4 S{var.Delay}
	elif (var.RunTime - state.time) > 60 
		set var.Delay = var.ShortDelay
		M291 R{var.FileName} T{var.Delay} S1 P{"Print start deferred for " ^ var.HoursLeft ^ " hrs : " ^ var.MinutesLeft ^ " mins : " ^ var.SecondsLeft ^ " secs - " ^ var.RunTime}
		G4 S{var.Delay}
	elif (var.RunTime - state.time) > 10 
		set var.Delay = 5
		set var.timeLeft = floor(var.RunTime - state.time)
		M291 R{var.FileName} T{var.Delay} S1 P{"Print starting in " ^ floor(var.RunTime - state.time) ^ " seconds"}
		M300 S{var.BeepFrequencyLow} P{var.BeepDuration}
		G4 S{var.Delay}
	else
		set var.Delay = 1
		M291 R{var.FileName} T{var.Delay} S0 P{"Print starting in " ^ floor(var.RunTime - state.time) ^ " seconds"}
		M300 S{var.BeepFrequencyHigh} P{var.BeepDuration}
		G4 S{var.Delay}
	if exists(param.X) && (var.Loops = param.X)
		break
M118 S"Starting Deferred Print" 
M300 S{floor(var.BeepFrequencyHigh * 1.2)} P1000
G4 S2