;CreateMultiTempMaps.g
; used to create multiple height maps based on varying bed temps
; adjust file locations as required.  Must be same in LoadMap.g
;
M291 P"This process cannot be manually stopped.  Do not leave unattended.  Ready to begin?" R"Notice" S3

var AmbientTemp = 30 ; bed must be below this value to be considered "Cold"
var HighTemp = 100
var MediumTemp = 70
var LowTemp = 50
var HighTempMap = "0:/sys/heightmaps/MighTempMap.csv"
var MediumTempMap = "0:/sys/heightmaps/MediumTempMap.csv"
var LowTempMap = "0:/sys/heightmaps/LowTempMap.csv"
var ColdBedMap = "0:/sys/heightmaps/ColdBedMap.csv"
var TempTolerance = 1 ; temp must be within this value- will be set in M116

if heat.heaters[0].current > var.AmbientTemp
	M140 S-276 ; turn off bed
	M291 P"Waiting for bed to cool to ambient" R"Cold Map" S1 T3
	while heat.heaters[0].current > var.AmbientTemp
		echo "waiting for bed to reach ambient - Current = " ^ heat.heaters[0].current ^ " Ambient = " ^ var.AmbientTemp
		G4 S10

if move.axes[0].homed !=true || move.axes[1].homed !=true || move.axes[2].homed !=true
	M291 P"Homing required.  Please wait" R"Homing" S1 T3
	G28 ; home all if required

M291 P"Creating cold bed map" R"Cold Map" S1 T3
G29 S0 ; create bed mesh
if result !=0
	M140 S-276 ; turn off bed
	abort "Failed to create height map"
G29 S3 P{var.ColdBedMap} ; save mesh to seperate file

if result !=0
	abort "Failed to create height map"

G29 S2 ; clear height map

M190 R{var.LowTemp}
M291 P"Heating for next map" R"Heating" S1 T3
M116 H0 S{var.TempTolerance}; wait for any temp changes on bed to be within X degrees of target
M291 P"Creating low temp bed map" R"Low Temp Map" S1 T3
G29 S0 ; create bed mesh
if result !=0
	M140 S-276 ; turn off bed
	abort "Failed to create height map"
G29 S3 P{var.LowTempMap}
if result !=0
	M140 S-276 ; turn off bed
	abort "Failed to create height map"

G29 S2 ; clear height map

M190 R{var.MediumTemp}
M291 P"Heating for next map" R"Heating" S1 T3
M116 H0 S{var.TempTolerance}; wait for any temp changes on bed to be within X degrees of target
M291 P"Creating medium temp bed map" R"Medium Temp Map" S1 T3
G29 S0 ; create bed mesh
if result !=0
	M140 S-276 ; turn off bed
	abort "Failed to create height map"
G29 S3 P{var.MediumTempMap}
if result !=0
	M140 S-276 ; turn off bed
	abort "Failed to create height map"

G29 S2 ; clear height map

M190 R{var.HighTemp}
M291 P"Heating for next map" R"Heating" S1 T3
M116 H0 S{var.TempTolerance}; wait for any temp changes on bed to be within X degrees of target
M291 P"Creating high temp bed map" R"High Temp Map" S1 T3
G29 S0 ; create bed mesh
if result !=0
	M140 S-276 ; turn off bed
	abort "Failed to create height map"
G29 S3 P{var.HighTempMap}
if result !=0
	M140 S-273 ; turn off bed
	abort "Failed to create height map"

M140 S-276 ; turn off bed
M291 P"Process complete" R"Done!" S1 T3
