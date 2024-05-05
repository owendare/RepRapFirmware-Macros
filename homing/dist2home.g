; dist2home.g
; should be called by driver-stall.g
; ASSUMES HOMING TO MINIMA!!
; only accepts X and Y axes
; assumes X is axes[0] and Y is axes[1]

; send axis by using A parameter
; send threshold for number of steps to constitute false positive as S parameter
; send driver number as D paramater
; send file position of error from driver-stall as R parameter
; e.g.
; M98 P"dist2home.g" A"Y" S"3" D"1" R"43251"

; **********adjust as required**********
var dist2move = -500 ; set greater than all axies length
var thisAxis = "X" ; default to x axis,but can be changed if parameter sent
var moveSpeed = 600; speed during  homing moves
var homeOnError = true ; home axes is error found
var return = true ; return to start position
var logErrors = true ; save details to a log file
var logFile =  "0:/sys/driver_stall_log.txt" ; location of log file
var maxErrorSteps = 3 ; can be overwritten by param.S
var zLift = 2 ; amount to lift Z before moving
var adjustOnError = true; call auto adjust on measured error
var adjustOnFalseAlarm = true ; call auto adjust on false alarm
var adjustMacro = "0:/macros/homing/auto_adjust_stall.g"  ; file to run if automatic adjustments are enabled
;*****************************************

; don't edit below here
var stepX =  {1  / move.axes[0].stepsPerMm}
var stepY=  {1 / move.axes[1].stepsPerMm}
var microStepsX = var.stepX / move.axes[0].microstepping.value
var microStepsY = var.stepY / move.axes[1].microstepping.value
var currentXlimit = move.axes[0].min
var currentYlimit = move.axes[1].min
var currentX = move.axes[0].machinePosition
var currentY = move.axes[1].machinePosition
var currentZ = move.axes[2].machinePosition
var xMove = var.dist2move ; will be reset as needed
var yMove = var.dist2move ; will be reset as needed
var searchPosX = move.axes[0].machinePosition
var searchPosY = move.axes[1].machinePosition
var hasErrorX = false;
var hasErrorY = false;
var measuredError = 0
var filePos = 0
if exists(param.A)
	set var.thisAxis = param.A
if exists(param.S)
	set var.maxErrorSteps = max(1,floor(param.S)) ; set max error steps to not less than one, or param.S
if exists(param.R)
	set var.filePos = param.R
var maxErrorX = var.maxErrorSteps * var.stepX
var maxErrorY = var.maxErrorSteps * var.stepY	

if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
	echo "Machine not homed"
	M99

M400 ; wait for any moves to stop
G60 S5 ; save position to slot 5


echo "selected axis is " ^ var.thisAxis
echo "start position X" ^ var.currentX ^ " Y" ^ var.currentY
if var.thisAxis = "X"
	set var.yMove = 0
	echo "Move amount is " ^ var.xMove
	G92 X0 ; Set current X position to 0
	G4 P100
	G91
	G1 Z{var.zLift} F120; raise Z 
	M400
	G1 H3 X{var.xMove}  F{var.moveSpeed}; Home to selected axis to minimum and set the axis limit
	M400
	set var.searchPosX =  move.axes[0].min    -  var.currentXlimit 
	echo  "Dist: " ^ abs(var.searchPosX)  ^ " Start: " ^  var.currentX
	set var.measuredError = abs(var.currentX - abs(var.searchPosX)) 
	if  var.measuredError <= var.maxErrorX
		set var.hasErrorX = false
		echo "Error amount on X ("^ var.measuredError ^ "mm) is less than or equal to " ^ var.maxErrorSteps ^ " steps " ^ "(" ^ var.maxErrorX ^ "mm)"
		
	else
		set var.hasErrorX = true
		echo "Measured error on X is : " ^  var.measuredError  ^  " mm" 
	echo "Full steps : " ^ floor(var.measuredError/var.stepX) ^ " + MicroSteps : " ^ floor(mod(var.measuredError,var.stepX)/var.microStepsX)
	M208 S1 X{var.currentXlimit} Y{var.currentYlimit} ; Set axis limit back to original
	M208 ; report axis setting
	G90 ; absolute moves
	G92 X{var.currentXlimit}
		
elif var.thisAxis = "Y"
	set var.xMove = 0
	G92 Y0 ; Set current position to 0
	G91 ; set relative moves
	G1 H3 Y{var.yMove} F{var.moveSpeed}; Home to selected axis to minimum and set the axis limit
	M400
	echo  "Dist: " ^ abs(var.searchPosY)  ^ " Start: " ^  var.currentY
	set var.measuredError = abs(var.currentY - abs(var.searchPosY)) 
	if  var.measuredError <= var.maxErrorY
		set var.hasErrorY = false
		echo "Error amount on Y ("^ var.measuredError ^ "mm) is less than or equal to " ^ var.maxErrorSteps ^ " steps " ^ "(" ^ var.maxErrorY ^ "mm)"
		
	else
		set var.hasErrorY = true
		echo "Measured error on Y is : " ^  var.measuredError  ^  " mm  :  Steps = "  ^  var.measuredError / var.stepY
	echo "Full steps : " ^ floor(var.measuredError/var.stepY) ^ " + MicroSteps : " ^ floor(mod(var.measuredError,var.stepY)/var.microStepsY)
	M208 S1 X{var.currentXlimit} Y{var.currentYlimit} ; Set axis limit back to original
	M208 ; report axis settings
	G90 ; absolute moves
	G92 Y{var.currentYlimit}
	
else
	echo "Undefined axis sent: " ^ param.A
	echo "Exiting macro with no action"
	G90 ; absolute moves
	M99 ; exit macro
		
G90	; absolute moves


if var.homeOnError	
	if var.hasErrorX
		echo "homing X"	
		G28 X
	if var.hasErrorY
		echo "homing Y"
		G28 Y
	G1 R5 Z0 ; restore Z position
M400
		
		
if var.return
	G1 R5 Z{var.zLift} F60 
	G1 R5 X0 Y0 Z{var.zLift} F3600; move back to original position
	G1 R5 Z0 F60 ; lower Z to original
	M400
	echo "Position restored"
	;G92 Y{var.currentYlimit}. X{var.currentX} Z{var.currentZ}; Set current position as original
	
if var.hasErrorX || var.hasErrorY
	if var.logErrors
		if !fileexists(var.logFile)
			echo >{var.logFile} "Driver stall log"
			echo >>{var.logFile} "*******************************************"
		echo >>{var.logFile} state.time
		echo >>{var.logFile} "Print job: " ^ job.file.fileName ^ ""
		echo >>{var.logFile} "File position: " ^ job.filePosition ^ " : First report @ " ^ var.filePos
		if var.hasErrorX
			echo >>{var.logFile} "Error amount X:" ^  var.currentX - abs(var.searchPosX) ^  " mm"
			echo >>{var.logFile} "Full steps : " ^ floor(var.measuredError/var.stepX) ^ " + MicroSteps : " ^ floor(mod(var.measuredError,var.stepX)/var.microStepsX)
		if var.hasErrorY
			echo >>{var.logFile}  "Error amount Y:" ^ var.currentY - abs(var.searchPosY)   ^  " mm - Steps = "  ^  abs(var.currentY - abs(var.searchPosY) ) / var.stepY
			"Full steps : " ^ floor(var.measuredError/var.stepY) ^ " +  MicroSteps : " ^ floor(mod(var.measuredError,var.stepY)/var.microStepsY)
		echo >>{var.logFile} "*******************************************"
	if var.adjustOnError	
		M98 P{var.adjustMacro} D{param.D}
else
	if !fileexists(var.logFile)
		echo >{var.logFile} "Driver stall log"
		echo >>{var.logFile} "*******************************************"
	echo >>{var.logFile} state.time
	echo >>{var.logFile} "Print job: " ^ job.file.fileName ^ ""
	echo >>{var.logFile} "File position: " ^ job.filePosition ^ " : First report @ " ^ var.filePos
	echo >>{var.logFile} "Stall detected on drive " ^ var.thisAxis ^ " was lower than threshold"
	echo >>{var.logFile} "*******************************************"
	if var.adjustOnFalseAlarm	
		M98 P{var.adjustMacro} D{param.D}

; turn on LED
M42 P5 S1
; set the LED timeout to 20 minutes from now
if exists(global.LedTimeout)
	set global.LedTimeout = state.upTime + 1200

	
