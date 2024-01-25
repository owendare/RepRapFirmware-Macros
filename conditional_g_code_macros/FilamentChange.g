; ChangeFilament.g
; requires RRF 3.5 or later!

; list of filaments must follow rules for array
https://docs.duet3d.com/User_manual/Reference/Gcode_meta_commands#array-expressions

var filaments = {"PLA","ABS","PETG","TPU","NYLON","CF","PCABS","ASA",} ; list your filaments here
var maxBtns = 5;  Max number of buttons per page on PanelDue.  Adjust as required.  5 works OK on 7"paneldue

; don't change below here

var thisTool = state.currentTool
if var.thisTool = -1
	abort "No tool selected"
var thisFilament = move.extruders[tools[var.thisTool].extruders[0]].filament
var newFilament = null

var thisPage = vector(var.maxBtns,"") 
var numPages = floor(#var.filaments / (var.maxBtns - 1))
if mod(#var.filaments , var.maxBtns - 1) > 0
	set var.numPages = var.numPages + 1
var pagesDone = 0;
var btnsDone = 0
var nextFilament = ""
var nextItem = 0
while var.pagesDone < var.numPages 
	set var.thisPage = vector(var.maxBtns,"")
	set var.btnsDone = 0 
	while var.btnsDone < var.maxBtns-1
		set var.nextItem = iterations + (var.pagesDone * (var.maxBtns-1))
		if var.nextItem = #var.filaments
			break
		set var.thisPage[var.btnsDone] = var.filaments[var.nextItem]
		set var.nextFilament =  var.filaments[var.nextItem]
		set var.btnsDone = var.btnsDone + 1		
	if var.pagesDone = var.numPages - 1
		set var.thisPage[{var.maxBtns-1}] = "Cancel"
	else
		set var.thisPage[{var.maxBtns-1}] = "Next"
	set var.pagesDone = var.pagesDone + 1
	M291 P"Select filament" S4 K{var.thisPage}
	if input = var.maxBtns-1
		continue 
	else
		set var.newFilament = var.thisPage[input]
		break
if (var.newFilament = null) || (var.newFilament = "")
	abort "No filaments chosen"
else
	echo "Filament chosen : ", var.newFilament, " : commence change"
if var.newFilament = "noFilament"
	M701 S{var.newFilament}
	if result != 0 
		abort "Error during loading"
	M703	
else
	if (var.thisFilament != "noFilament") && (var.thisFilament != null)
		M702
		M701 S{var.newFilament}
		if result != 0 
			abort "Error during loading"
		M703
	