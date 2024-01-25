; ChangeFilament.g
; requires RRF 3.5 or later!

; list of filaments must follow rules for array
; https://docs.duet3d.com/User_manual/Reference/Gcode_meta_commands#array-expressions

var filaments = {"ABS","ASA","EDGE","eFlex","eLastic","FLEX","HIPS","NGEN","NYLON","PA-CF","PC","PCABS","PDVF","PEEK","PEI","PEKK","PET","PETG","PLA","POM","PP","PSU","PVA","SCAFF","TPE","TPU",} ; list your filaments here
var maxBtns = 10;  Max number of buttons per page on PanelDue.  Adjust as required.  5 works OK on 7"paneldue - 9 is max!

; don't change below here

var thisTool = state.currentTool

var allTools = vector(#tools,null)


if var.thisTool = -1
	if #tools > 1
		while iterations < #tools
			set var.allTools[iterations] =  tools[iterations].name ^ ""
		M291 S4 P"Select tool" K{var.allTools} F0
		T{input}
		G4 S1
		if state.currentTool = -1
			abort "No tool selected"
		else
			set var.thisTool = state.currentTool
	else
	T1
var thisExtruder = 0
var allExtruders = vector(#tools[var.thisTool].extruders,null)
if #tools[var.thisTool].extruders > 1
	
	while iterations < #tools[var.thisTool].extruders
		set var.allExtruders[iterations] = iterations ^ ""
	M291 P"Select extruder" S4 K{var.allExtruders} F0
	set var.thisExtruder = input
			
var thisFilament = move.extruders[tools[var.thisTool].extruders[var.thisExtruder]].filament
var newFilament = null
if var.maxBtns > 10
	set var.maxBtns = 10
	echo "Paneldue can only display 10 buttons in total"
	echo "Max buttons has been reset"
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
	
; M701 only works if the tool only has one extruder
; If more than one extruder is present on the tool, we'll directly call the macros for load, unload and config
; It's unclear if the filament will be marked as loaded in DWC after this approach.

if var.newFilament = "noFilament"
		if #tools[var.thisTool].extruders > 1   
			M98 P{directories.filaments ^ var.newFilament ^ "/load.g"}  S{var.thisExtruder}
			M98 P{directories.filaments ^ var.newFilament ^ "/config.g"}  S{var.thisExtruder}	
		else
			M701 S{var.newFilament}
			if result != 0 
				abort "Error during loading"
			M703	
else
	if (var.thisFilament != "noFilament") && (var.thisFilament != null)
		
		if #tools[var.thisTool].extruders > 1   ; M701 only works if the too only has one extruder
			M98 P{directories.filaments ^ var.newFilament ^ "/unload.g"}  S{var.thisExtruder}
			M98 P{directories.filaments ^ var.newFilament ^ "/load.g"}  S{var.thisExtruder}
			M98 P{directories.filaments ^ var.newFilament ^ "/config.g"}  S{var.thisExtruder}	
		else
			M702
			M701 S{var.newFilament}
			if result != 0 
				abort "Error during loading"
			M703
	