;random-moves.g
; macro to do high speed moves to random positions.  a small amount of filament will be extruded to sop it burning
; note if run as a macro, it can't be interupted, so a print job is created.
; this can be cancelled by setting an output low, or by pause/cancel print
; speeds etc may be adjusted using the local variables provided.
; global variables will be created for use in the print job based on these.
var FileName = directories.gCodes ^ "random-moves-test.g" ; set output file name - will be placed in gcodes directory
var MinXPos = 80 ; minimum X position
var MaxXPos = 120 ; maximum X position
var MinYPos = 80 ; minimum Y position
var MaxYPos = 120 ; maximum Y position
var MinTravelSpeed = 9000 ; minimum travel speed
var MaxXYTravelSpeed = 24000 ; maximum XY travel speed
var MaxETravelSpeed = 12000 ; maximum XY travel speed
var XYJerk = 600 ; X & Y Jerk
var EJerk = 6000 ; E Jerk
var XYAcceleration = 6000 ; X & Y Acceleration
var EAcceleration = 6000 ; E Acceleration
var Extrude = true ; Set true to extrude small amounts
var ExtrudeAmount = 0.03 ; volume to extrude over full length move.  Will be scaled for  shorter moves
var Tool = 0 ; set tool to use if extruding
var Temp = 240 ; if extruding, set temp
var Standby = 180 ; standby temp
var OutPutState = 1 ; set output state to cancel
var OutputToCancel = 5 ;
var FanToMonitor = 0 ; set the fan number which will be used to scale the speed

; do not adjust below here
if job.file.fileName!=null
	echo "A print is running - macro canceled"
	M99
if !exists(global.minX)
	global minX = var.MinXPos                        ; minimum X position
else
	set global.minX = var.MinXPos

if !exists(global.maxX)
	global maxX = var.MaxXPos                       ; maximum X position
else
	set global.maxX = var.MaxXPos

if !exists(global.minY)
	global minY = var.MinYPos                        ; minimum Y position
else
	set global.minY = var.MinYPos

if !exists(global.maxY)
	global maxY = var.MaxYPos                       ; maximum Y position
else
	set global.maxY = var.MaxYPos

if !exists(global.minSpeed)
	global minSpeed = var.MinTravelSpeed                  ; minimum travel speed
else
	set global.NextX = var.MinTravelSpeed

if !exists(global.maxSpeed)
	global maxSpeed = var.MaxXYTravelSpeed                 ; max travel speed this will be scaled based on the part fan speed, so it can be controlled/reduced during the test
else
	set global.maxSpeed = var.MaxXYTravelSpeed

if !exists(global.outputIO)
	global outputIO = var.OutputToCancel                     ; tied to an output (LED) so we cabn interupt the "print" without a reset
else
	set global.outputIO = var.OutputToCancel

if !exists(global.FanControl) ; this fan will allow control of speed
	global FanControl = var.FanToMonitor
else
	set global.FanControl = var.FanToMonitor

if !exists(global.NextX)
	global NextX = max(random(global.maxX),global.minX) ; set next X move pos
else
	set global.NextX = max(random(global.maxX),global.minX)

if !exists(global.NextY)
	global NextY = max(random(global.maxY),global.minY) ; set next Y pos
else
	set global.NextY = max(random(global.maxY),global.minY)

if var.Extrude != true
	set var.ExtrudeAmount = 0

if !exists(global.ExtrudeValue)
	global ExtrudeValue = var.ExtrudeAmount
else
	set global.ExtrudeValue = var.ExtrudeAmount

if !exists(global.FeedAmount)
	global FeedAmount = global.ExtrudeValue / max(global.maxX,global.maxY) * max(global.NextX,global.NextY)
else
	set global.FeedAmount = global.ExtrudeValue / max(global.maxX,global.maxY) * max(global.NextX,global.NextY)


M566 X{var.XYJerk} Y{var.XYJerk} E{var.EJerk}       ; set maximum instantaneous speed changes (mm/min)
M203 X{var.MaxXYTravelSpeed} Y{var.MaxXYTravelSpeed} E{var.MaxETravelSpeed}  ; set maximum speeds (mm/min)
M201 X{var.XYAcceleration} Y{var.XYAcceleration} E{var.EAcceleration}     ; set accelerations (mm/s^2)
M83 ; set relative extruder moves
if fans[var.FanToMonitor].actualValue = 0
	M106 P{var.FanToMonitor} S1 ; make sure fan is on
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
	echo "Homing"
	G28
	if result != 0
		abort "Homing failed"

G1 X{global.minX + ((global.maxX-global.minX)/2)} Y{global.minY + ((global.maxY-global.minY)/2)} Z50 F3000 ; move to the centre of the range and 50mm above bed
if var.Extrude = true
	T{var.Tool} ; select tool
	echo "waiting for heaters"
	G10 T{var.Tool} S{var.Temp} R{var.Standby} ; set extruder temp
	M116 ; wait for temps
M291 P"Ready to start?" R"Ready" S3
echo "creating file: " ^ var.FileName
M28 {var.FileName}
while state.gpOut[{global.outputIO}].pwm = 1
	set global.NextX = max(random(global.maxX),global.minX)
	set global.NextY = max(random(global.maxX),global.minX)
	set global.FeedAmount=global.ExtrudeValue / max(global.maxX,global.maxY) * max(global.NextX,global.NextY)
	G1 X{global.NextX} Y{global.NextY} E{global.FeedAmount} F{max(random(global.maxSpeed),global.minSpeed)*fans[global.FanControl].actualValue};
	if result !=0
		abort "Could not execute move"
	M400
	G4 P1
echo "LED is off - moves cancelled"
M98 P"0:/sys/set_max_speeds.g" ; reset speeds to original
M0 ; run stop.g
M29 ; close file
echo "file created: " ^ var.FileName
;M32 "0:/gcodes/random-moves-test.g" ; start prnt job
M99
