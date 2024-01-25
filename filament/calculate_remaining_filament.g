;calculate_remaining_filament.g
; Calculate filament length on spool

var resultAsGlobal=true ; set to true f you want the result saved as a global variable called global.remainingFilamen
; Set filaments to be included to true
; Array format = {"FilamentName",Density g/cm3 (nn.nn),Include(true/false)}
; no more than 250 characters allowed on line
var FilamentDensities = {{"ABS",1.04,true,},{"ASA",1.07,false,},{"eFlex",1.12,true,},{"eLastic",1.14,true,},{"PA-CF",1.40,true,},{"PEEK",1.26,false,},{"PETG",1.27,true,},{"PLA",1.24,true,},{"TPU",1.21,true,},}

;create array with default empty spool weights
var emptySpoolWeights={{"eSun Black",224},{"eSun Clear",248},{"Auraurum",250},{"Prusament",205},{"3D Fillies",250},} ; must be an array.  Even if only one value, last value must be followed by a comma

; create an array for all filament diameters used
var FilamentDiameters = {1.75,} ; must be an array.  Even if only one value, last value must be followed by a comma
;var FilamentDiameters = {1.75,2.85} ; must be an array.  Even if only one value, last value must be followed by a comma

;create an array with new spool weights (filament only)
var newSpools = {1.0,} ; must be an array.  Even if only one value, last value must be followed by a comma
; var newSpools = {0.25,0.3,0.5,1.0,2.0,5.0,} ; must be an array.  Even if only one value, last value must be followed by a comma

; ##############   Don't modify below here ###################

var includedCount = 0 ; leave at zero

; Create an array with just our list of included filaments
while iterations < #var.FilamentDensities
	if var.FilamentDensities[iterations][2] == true
		set var.includedCount  = var.includedCount + 1
var displayList = vector(var.includedCount,null)
var displayedData = vector(var.includedCount,{null,null,null})
var recordNum = 0
while iterations < #var.FilamentDensities
	if var.FilamentDensities[iterations][2] == true
		set var.displayList[var.recordNum]	= var.FilamentDensities[iterations][0]
		set var.displayedData[var.recordNum] = var.FilamentDensities[iterations]
		set var.recordNum = var.recordNum + 1

; display out choice list
M291 S4 K{var.displayList} P"Choose Filament type" 
var ChosenType = input

; create an array of strings of the filament diameters for use by M291
var thisList = vector(#var.FilamentDiameters,null)
while iterations < #var.FilamentDiameters
	set var.thisList[iterations] = var.FilamentDiameters[iterations] ^ ""
var diameter = 0

; If there's more than one diameter we'll display a choice
if #var.thisList > 1
	M291 S4 K{var.thisList} P"Choose diameter" F0
	set var.diameter = var.FilamentDiameters[input]
else
	set var.diameter = var.FilamentDiameters[0]

; check if it's a new spool or partial one
var weight = 0
var isNewSpool = true
M291 S4 K{"New spool", "Part spool",} P"Select amount left on spool"
if input = 1
	M291 S6 L250 H5500 P"Enter total spool + filament weight (grams)" F1000
	set var.weight = input
	set var.isNewSpool = false
else
	var spools = vector(#var.newSpools,null)
	while iterations < #var.newSpools
		set var.spools[iterations] = var.newSpools[iterations] ^ ""
	
	; if we have more than one new spool weight, we'll show a choice
	if #var.newSpools > 1
		M291 S4 K{var.spools} P"Select new filament weight (excluding spool) in KG's"
		set var.weight = var.newSpools[input]*1000 ; convert to grams
	else
		set var.weight = var.newSpools[0]*1000 ; convert to grams
	
;if there's more than one empty spool weight we'll dislay a choice

set var.thisList = vector(#var.emptySpoolWeights,null)
while iterations < #var.emptySpoolWeights
	set var.thisList[iterations] = var.emptySpoolWeights[iterations][0]]
	
	
var spoolWeight= 0
if (#var.thisList > 1) && (var.isNewSpool=false)
	M291 S4 K{var.thisList} F0 P"Choose empty spool type"
	set var.spoolWeight = var.emptySpoolWeights[input][1]]
else
	set var.spoolWeight = var.emptySpoolWeights[0][1]]
var remaining = 0
if var.isNewSpool = true
	set var.remaining = var.weight
else
	set var.remaining = var.weight - var.spoolWeight
var ccLeft = var.remaining / var.displayedData[var.ChosenType][1]
var CCperMM = (3.1416 * pow(var.diameter/2,2)/1000) 

var FilamentLeft = var.ccLeft / var.CCperMM
M291 S2 P{"Remaining filament is aprox " ^ floor(var.FilamentLeft) ^ " mm (" ^ var.FilamentLeft/1000 ^ " meters)"}

; chck if we are to create a global variable
if var.resultAsGlobal
	M291 S4 P"Create/update global variable?" K{"No","Yes"} R"global.remainingFilament" F1
	if input = 1
		if !exists(global.remainingFilament)
			global remainingFilament = floor(var.FilamentLeft)
		else
			set global.remainingFilament = floor(var.FilamentLeft)
	else
		echo "Global variable not set"