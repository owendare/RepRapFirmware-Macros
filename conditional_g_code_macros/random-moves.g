;random-moves.g
; macro to do high speed moves to random positions.  a small amount of filament will be extruded to sop it burning
; note if run as a macro, it can't be interupted, so a print job is created.
; this can be cancelled by setting an output low, or by pause/cancel print
; speeds etc may be adjusted using the local variables provided.
; global variables will be created for use in the print job based on these.

var MinTravelSpeed = 18000 ; minimum travel speed.  Move speeds will be between this and maxxy travel speed unless limited by jerk/accel
var MaxXYTravelSpeed = 24000 ; maximum XY travel speed
var MaxETravelSpeed = 600 ; maximum E travel speed
var XYJerk = 720 ; X & Y Jerk
var EJerk = 6000 ; E Jerk
var XYAcceleration = 6000 ; X & Y Acceleration
var EAcceleration = 6000 ; E Acceleration

var useDefaultSpeeds = true; if set to false then accelleration, max speed and jerk settings below will be used.
M291 S4 R"Speeds" P"Use increased speeds and accelerations?" K{"Yes","No",} F0
if input = 0
	set var.useDefaultSpeeds = false
else
	M98 P""0:/sys/set_max_speeds.g" ; reset defaults

M291 P"Set maximum speed to use in mm/sec" R"Speed" S6 F{var.MaxXYTravelSpeed/80} L50 H{var.MaxXYTravelSpeed/60}
set var.MaxXYTravelSpeed = input * 60

var Extrude = true ; Set true to extrude small amounts
var ExtrudeAmount = 0.08 ; amount to extrude per mm of travel
var Tool = 0 ; set tool to use if extruding
var Temp = heat.coldExtrudeTemperature + 10 ; if extruding, set temp
var Standby = 150 ; standby temp
var OutPutState = 1 ; set output state to cancel
var OutputToCancel = 5 ;
var FanToMonitor = 0 ; set the fan number which will be used to scale the speed
var defaultFanPos = 0.8
var Zposition = 50 ; how far off the bed will moves be carried out
if exists(global.myFile)
	set global.myFile = ""
else
	global myFile = ""

if exists(global.doPause)
	set global.doPause=1
else
	global doPause=1
	
M291 S7 L4 H20 P"Enter print file name" R"File" F"random-moves-test.g"
set global.myFile = directories.gCodes ^ input ; set output file name - will be placed in gcodes directory
M291 P"Enter minimum X position for moves" R"Min X" F80 L{move.axes[0].min} H{move.axes[0].max} S6
var MinXPos = input ; minimum X position
M291 S6 P"Enter maximum X position for moves" R"Max X" L{var.MinXPos} H{move.axes[0].max} F120
var MaxXPos = input ; maximum X position
M291 S6 P"Enter minimum Y position for moves" R"Min Y" L{move.axes[1].min} H{move.axes[1].max} F80
var MinYPos = input ; minimum Y position
M291 S6 P"Enter maximum Y position for moves" R"Max Y" L{var.MinYPos} H{move.axes[1].max} F120
var MaxYPos = input ; maximum Y position

M291 S4 P"Extrude during moves?" K{"Yes","No",} F0
if input = 0
	set var.Extrude = true
else
	set var.Extrude = false

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
	set global.minSpeed = var.MinTravelSpeed
if !exists(global.maxSpeed)
	global maxSpeed = var.MaxXYTravelSpeed                 ; max travel speed this will be scaled based on the part fan speed, so it can be controlled/reduced during the test
else
	set global.maxSpeed = var.MaxXYTravelSpeed
if !exists(global.outputIO)
	global outputIO = var.OutputToCancel                     ; tied to an output (LED) so we cabn interupt the "print" without a reset
else
	set global.outputIO = var.OutputToCancel
if !exists(global.FanCtrl) ; this fan will allow control of speed
	global FanCtrl = var.FanToMonitor
else
	set global.FanCtrl = var.FanToMonitor
if !exists(global.NextX)
	global NextX = max(random(global.maxX),global.minX) ; set next X move pos
else
	set global.NextX = max(random(global.maxX),global.minX)
if !exists(global.NextY)
	global NextY = max(random(global.maxY),global.minY) ; set next Y pos
else
	set global.NextY = max(random(global.maxY),global.minY)

if !exists(global.xNow)
	global xNow = move.axes[0].machinePosition
else
	set global.xNow = move.axes[0].machinePosition
if !exists(global.yNow)
	global yNow = move.axes[0].machinePosition
else
	set global.yNow = move.axes[0].machinePosition

if !exists(global.thisLength)
	global thisLength = 0
else
	set global.thisLength = 0

if var.Extrude != true
	set var.ExtrudeAmount = 0
if !exists(global.ExtrudeValue)
	global ExtrudeValue = var.ExtrudeAmount
else
	set global.ExtrudeValue = var.ExtrudeAmount
if !exists(global.Feed)
	global Feed = global.ExtrudeValue * global.thisLength
else
	set global.Feed = global.ExtrudeValue * global.thisLength
	
if !exists(global.Speed)
	global Speed = global.minSpeed
else
	set global.Speed = global.minSpeed
	
if var.useDefaultSpeeds = false
	M566 X{var.XYJerk} Y{var.XYJerk} E{var.EJerk}       ; set maximum instantaneous speed changes (mm/min)
	M203 X{var.MaxXYTravelSpeed} Y{var.MaxXYTravelSpeed} E{var.MaxETravelSpeed}  ; set maximum speeds (mm/min)
	M201 X{var.XYAcceleration} Y{var.XYAcceleration} E{var.EAcceleration}     ; set accelerations (mm/s^2)
else
	set var.MinTravelSpeed = floor(min(move.axes[0].speed,move.axes[1].speed))
	set var.MaxXYTravelSpeed = floor(min(move.axes[0].speed,move.axes[1].speed))
	set var.MaxETravelSpeed = move.extruders[tools[var.Tool].extruders[0]].speed
	M291 S5 P"Set move speed (mm/sec) when fan set to max" R"Speed" L10 H{floor(var.MaxXYTravelSpeed/60)} F{floor(var.MaxXYTravelSpeed/60)}
	set global.minSpeed = input * 60
	set global.maxSpeed = input * 60 
M83 ; set relative extruder moves
if fans[var.FanToMonitor].actualValue != var.defaultFanPos
	M106 P{var.FanToMonitor} S{var.defaultFanPos} ; make sure fan is on and at correct speed
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
	echo "Homing"
	G28
	if result != 0
		abort "Homing failed"
G1 X{global.minX + ((global.maxX-global.minX)/2)} Y{global.minY + ((global.maxY-global.minY)/2)} Z{var.Zposition} F3000 ; move to the centre of the range and 50mm above bed
if var.Extrude = true
	M291 S4 P"Do filament change pauses?" R"Pause?" K{"Yes","No",} F0
		set global.doPause = input
	T{var.Tool} ; select tool
	M291 S6 P"Set extruder temp" R"Temp" L{heat.coldExtrudeTemperature+5} H{heat.heaters[tools[var.Tool].heaters[0]].max-20} F{var.Temp}
	set var.Temp = input
	echo "waiting for heaters"
	G10 T{var.Tool} S{var.Temp} R{var.Standby} ; set extruder temp
	M116 ; wait for temps
if exists(global.loopCount)
	set global.loopCount = 0.0
else
	global loopCount = 0.0

M593 P"none" ; turn off input shaping
M572 D{var.Tool} S0 ; turn off pressure advance

echo "creating file: " ^ global.myFile
echo >{global.myFile} ";",global.myFile
echo >>{global.myFile} "while state.gpOut[{global.outputIO}].pwm = 1"
echo >>{global.myFile} "   set global.loopCount = global.loopCount + 1.0"
if global.doPause = 0
	echo >>{global.myFile} "   if global.loopCount = 10"
	echo >>{global.myFile} "      M600"
	echo >>{global.myFile} "      set global.loopCount = 0"
echo >>{global.myFile} "   set global.xNow = move.axes[0].userPosition"
echo >>{global.myFile} "   set global.yNow = move.axes[1].userPosition"
echo >>{global.myFile} "   set global.NextX = max(random(global.maxX),global.minX)"
echo >>{global.myFile} "   set global.NextY = max(random(global.maxX),global.minX)"
echo >>{global.myFile} "   set global.thisLength = sqrt(pow(abs(global.xNow-global.NextX),2) + pow(abs(global.yNow-global.NextY),2))"
echo >>{global.myFile} "   set global.Feed=global.ExtrudeValue * global.thisLength"
echo >>{global.myFile} "   set global.Speed = max(random(global.maxSpeed),global.minSpeed)*fans[global.FanCtrl].actualValue"
echo >>{global.myFile} "   G1 X{global.NextX} Y{global.NextY} E{global.Feed} F{global.Speed}"
echo >>{global.myFile} "   if result !=0"
echo >>{global.myFile} "      abort ""Could not execute move"""
echo >>{global.myFile} "   M400"
echo >>{global.myFile} "   G4 P1"
echo >>{global.myFile} "echo ""Input is off - moves cancelled"""
echo >>{global.myFile} "M98 P""0:/sys/set_max_speeds.g"" ; reset speeds to original"
echo >>{global.myFile} "M0 ; run stop.g"
echo "file created: " ^ global.myFile
M400
M291 S4 P"Start test job?" R"Ready?" K{"Yes","No",} F0
if input = 0
	M32 "0:/gcodes/random-moves-test.g" ; start print job
	M99
else
	if var.Extrude = true
		M291 R"Warning" P"Heaters are active!  Do not leave unattended" S1