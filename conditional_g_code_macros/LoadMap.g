; LoadMap.g
; requires RRF 3.3b2 or later!
; called to load height map according to current bed temp
; Bed must be at target temp so use M116 before calling this macro
;height maps must be already created
; adjust file location and file name of height maps to suit your system
; adjust temps to suit your requirements.
; Remember M116 may not wait until bed is fully at temp so set these a few degrees lower than target temp in slicer
;TempTolerance value will be used in M116 to ensure bed is stable to within +/- this amount from target
; ********** Macro assumes bed heater is H0! ***************
var HighTemp = 98
var MediumTemp = 68
var LowTemp = 48
var HighTempMap = "0:/sys/heightmapHigh.csv"
var MediumTempMap = "0:/sys/heightmapMedium.csv"
var LowTempMap = "0:/sys/heightmapLow.csv"
var ColdBedMap = "0:/sys/heightmapCold.csv"
var ExitIfBedOff = false ; set to true if you don't want to load a height map if the bed is turned off
var AbortIfErrorLevel = 1 ; abort process if error level check is equal to or greater than this.  1 = warning, 2 = error
var TempTolerance = 1 ; temp must be within this value- will be set in M116
; Do not adjust under this line unless you know what you're doing


if var.AbortIfErrorLevel < 1 || var.AbortIfErrorLevel > 2
	echo "AbortIfErrorLevel value must be either 1 or 2"
	abort

echo "Waiting for bed temp to stabilise"
M116 H0 S{var.TempTolerance}; wait for any temp changes on bed to be within X degrees of target

if move.axes[0].homed !=true || move.axes[1].homed !=true || move.axes[2].homed !=true
	echo "Machine not homed - height map operation cancelled"
	abort ; cancel macro & print

G29 S2 ; Clear current height map

if {var.ExitIfBedOff == true} && {heat.heaters[0].state == "off"}
	echo "Bed is off.  No height map required"
	M99 ; exiting macro but not cancelling print

;now check temps and load the height map to suit
if heat.heaters[0].current >= var.HighTemp
	G29 S1 P{var.HighTempMap} ; if temp is 100 or greater load this file
	if result >= var.AbortIfErrorLevel
		echo "Failed to load height map " ^  {move.compensation.file}
		abort ; cancel macro and print
elif heat.heaters[0].current >= var.MediumTemp ; if temp is less than 100 AND greater then  or equal to 70 load this file
	G29 S1 P{var.MediumTempMap}
	if result >= var.AbortIfErrorLevel
		echo "Failed to load height map " ^  {move.compensation.file}
		abort ; cancel macro and print
elif heat.heaters[0].current >= var.LowTemp ; if temp is less than 70 AND greater then  or equal to 50 load this file
	G29 S1 P{var.LowTempMap}
	if result >= var.AbortIfErrorLevel
		echo "Failed to load height map " ^  {move.compensation.file}
		abort ; cancel macro and print
		; START COLD BED MAP
else ;      - temp is under 50 , so we might have a cold bed height map - otherwise delete COLD BED MAP section
	G29 S1 P{var.ColdBedMap} ;
	if result >= var.AbortIfErrorLevel
		echo "Failed to load height map " ^  {move.compensation.file}
		abort ; cancel macro and print
;END COLD BED MAP

; START FINAL CHECK
;do a final check and report height map loaded ; comment this out if you want no height map when under 50 degrees
if move.compensation.file !=null
	echo "Height map loaded is  " ^  {move.compensation.file}
else
	"MACRO ERROR: No heightmap has been loaded"
	abort ; cancel print
; END FINAL CHECK

;if you don't use FINAL CHECK section, uncomment this line
;echo "Height map loaded is  " ^  {move.compensation.file}