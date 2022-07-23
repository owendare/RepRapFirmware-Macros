; start_after_delay.g
; should be called from slicer start gcode or start.g BEFORE any heating actions
; Accepts four parameters
; R = start time.  Must have the format R{yyyy-mm-ddThh:mm:ss} e.g R{2022-01-04T13:30:00} - seconds will be ignored
; S = number of minutes to delay
; H = number of hours to delay
; X = a testing parameter to allow early exit after X loops
; times are added to achieve total delay
; if R parameter (start time) is passed, H & S are ignored
; at least one time parameter must be passed
; e.g 
; M98 P"start_after_delay.g" H4 S20 ; (delay the start of the print for 4 hours 20 minutes)
; M98 P"start_after_delay.g" H1     ; (delay the start of the print for 1 hour)
; M98 P"start_after_delay.g" S10    ; (delay the start of the print for 10 minutes)
var LongDelay = 60   ; Delay between message updates if time left is greater than 1 hour
var MediumDelay = 20 ; Delay between message updates if time left is less than 1 hour but greater than 10 minutes
var ShortDelay = 10  ; Delay between message updates if time left less than 10 minutes
; at less than one minute updates will happen every 5 seconds
; at less than 10 seconds, updates will happen every second
var BeepFrequencyLow = 1000 ; frequency (low pitch) of beep play every var.ShortDelay when one minute left
var BeepFrequencyHigh = 3000 ;  frequency (high pitch) of beep play every var.ShortDelay when ten seconds left
var BeepDuration = 200 ; duration of beep in milliseconds (must be less than one second) - note 1 second will cause constant beep for last 10 seconds

; ************** Don't change below this line *****************

var FileName = "No file selected"

if !exists(param.X)
	if (job.file.fileName = "") || (job.file.fileName=null)
		abort "No print in progress"
	else
		set var.FileName=job.file.fileName
else
	if (job.file.fileName!=null)
		set var.FileName=job.file.fileName

if var.BeepDuration > 1000
	echo "Invalid beep duration - reset to 1/2 second)
	set var.BeepDuration = 1000

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
while state.time < var.RunTime
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
		M291 R{var.FileName} T{var.Delay} S0 P{"Print start deferred for " ^ var.HoursLeft ^ " hrs : " ^ var.MinutesLeft ^ " mins  - " ^ var.RunTime}
		G4 S{var.Delay}
	elif (var.RunTime - state.time) > 60 
		set var.Delay = var.ShortDelay
		M291 R{var.FileName} T{var.Delay} S0 P{"Print start deferred for " ^ var.HoursLeft ^ " hrs : " ^ var.MinutesLeft ^ " mins : " ^ var.SecondsLeft ^ " secs - " ^ var.RunTime}
		G4 S{var.Delay}
	elif (var.RunTime - state.time) > 10 
		set var.Delay = 5
		M291 R{var.FileName} T{var.Delay} S0 P{"Print starting in " ^ floor((var.RunTime - state.time)) ^ " seconds"}
		M300 S{var.BeepFrequencyLow} P{var.BeepDuration}
		G4 S{var.Delay}
	else
		set var.Delay = 1
		M291 R{var.FileName} T{var.Delay} S0 P{"Print starting in " ^ floor((var.RunTime - state.time)) ^ " seconds"}
		M300 S{var.BeepFrequencyHigh} P{var.BeepDuration}
		G4 S{var.Delay}
	if exists(param.X)
		if (var.Loops = param.X)
			break
M118 S"Starting Deferred Print" 
M300 S{floor(var.BeepFrequencyHigh * 1.2)} P1000
G4 S2