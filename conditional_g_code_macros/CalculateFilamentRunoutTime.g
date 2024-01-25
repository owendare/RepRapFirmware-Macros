; CalculateFilamentRunoutTime.g
; Calculate thn aproximate time filament will run out

M291 S6 P"Enter weight of filament (excluding spool) in grams" F10 H1000 L1
var spoolWeight = input
var filamentDensity = 1.04
M291 S7 P"Enter filename to simulate" F"cube.gcode"
var fullName = directories.gCodes ^ input
var filamentUsed = 0
var filamentRunout = false
echo var.fullName
var startTime = state.time
var durationInSecs = 0
if !fileexists(var.fullName) 
    abort "File not found : " ^ var.fullName
else
    echo "Simulating " ^ var.fullName
    M37 P{var.fullName} S2 F1
    while state.status ="simulating"
        set var.filamentUsed = move.extruders[0].position * (3.1416 * pow(1.75/2,2)/1000) * var.filamentDensity
        if var.filamentUsed > var.spoolWeight
            set var.durationInSecs = job.duration
            echo "Filament exceeded at aprox " ^  {floor(var.durationInSecs /60)} ^ " minutes after start"
            G4 S1
            M25
            set var.filamentRunout  = true
            echo "If started now, print would run out of filament at aprox " ^ state.time + var.durationInSecs
            G4 S2
            while state.status="pausing"
                G4 S1
            M0
            M37 S0
            
        G4 P500
    if var.filamentRunout = false
        echo "Simulation finished without filament runout"
    