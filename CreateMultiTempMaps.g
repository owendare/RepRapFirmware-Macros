;CreateMultiTempMaps.g
; used to create multiple height maps based on varying bed temps
; adjust file locations as required.  Must be same in LoadMap.g
;
M291 P"This process cannot be manually stopped.  Do not leave unattended.  Ready to begin?" R"Notice" S3

var AmbientTemp = 36 ; bed must be below this value to be considered "Cold"
var HighTemp = 100
var MediumTemp = 70
var LowTemp = 50
var HighTempMap = "0:/sys/heightmapHigh.csv"
var MediumTempMap = "0:/sys/heightmapMedium.csv"
var LowTempMap = "0:/sys/heightmapLow.csv"
var ColdBedMap = "0:/sys/heightmapCold.csv"
var TempTolerance = 1 ; temp must be within this value- will be set in M116
var SoakTime = 180 ; time in seconds to wait for temp to stabilise to allow for over shoot

if heat.heaters[0].current > var.AmbientTemp
	M140 S0 R0 ; set active and standby temps to zero
	M140 S-276 ; turn off bed
	M291 P"Waiting for bed to cool to ambient" R"Cold Map" S1 T3
	while heat.heaters[0].current > var.AmbientTemp
		echo "waiting for bed to reach ambient - Current = " ^ heat.heaters[0].current ^ " Ambient = " ^ var.AmbientTemp
		G4 S10

if move.axes[0].homed !=true || move.axes[1].homed !=true || move.axes[2].homed !=true
	echo "Homing"
	M291 P"Homing required.  Please wait" R"Homing" S1 T3
	G28 ; home all if required

echo "Creating cold bed map"
M291 P"Creating cold bed map" R"Cold Map" S1 T3
G29 S0 ; create bed mesh
if result !=0
	M140 S0 R0 ; set active and standby temps to zero
	M140 S-276 ; turn off bed
	abort "Failed to create height map"
G29 S3 P{var.ColdBedMap} ; save mesh to seperate file

if result !=0
	abort "Failed to create height map"

G29 S2 ; clear height map

echo "Heating for nextmap"
M291 P"Heating for next map" R"Heating" S1 T3
M190 R{var.LowTemp}
M116 H0 S{var.TempTolerance}; wait for any temp changes on bed to be within X degrees of target
echo "waiting for temp to stabilise"
G4 S{var.SoakTime}
echo "Creating low temp bed map"
M291 P"Creating low temp bed map" R"Low Temp Map" S1 T3
G29 S0 ; create bed mesh
if result !=0
	M140 S-276 ; turn off bed
	abort "Failed to create height map"
G29 S3 P{var.LowTempMap}
if result !=0
	M140 S0 R0 ; set active and standby temps to zero
	M140 S-276 ; turn off bed
	abort "Failed to create height map"

G29 S2 ; clear height map

echo "Heating for nextmap"
M291 P"Heating for next map" R"Heating" S1 T3
M190 R{var.MediumTemp}
M116 H0 S{var.TempTolerance}; wait for any temp changes on bed to be within X degrees of target
echo "waiting for temp to stabilise"
G4 S{var.SoakTime}
echo "Creating medium temp bed map"
M291 P"Creating medium temp bed map" R"Medium Temp Map" S1 T3
G29 S0 ; create bed mesh
if result !=0
	M140 S-276 ; turn off bed
	abort "Failed to create height map"
G29 S3 P{var.MediumTempMap}
if result !=0
	M140 S0 R0 ; set active and standby temps to zero
	M140 S-276 ; turn off bed
	abort "Failed to create height map"

G29 S2 ; clear height map

echo "Heating for nextmap"
M291 P"Heating for next map" R"Heating" S1 T3
M190 R{var.HighTemp}
M116 H0 S{var.TempTolerance}; wait for any temp changes on bed to be within X degrees of target
echo "waiting for temp to stabilise"
G4 S{var.SoakTime}
echo "Creating high temp bed map"
M291 P"Creating high temp bed map" R"High Temp Map" S1 T3
G29 S0 ; create bed mesh
if result !=0
	M140 S0 R0 ; set active and standby temps to zero
	M140 S-276 ; turn off bed
	abort "Failed to create height map"
G29 S3 P{var.HighTempMap}
if result !=0
	M140 S-273 ; turn off bed
	abort "Failed to create height map"

M140 S0 R0 ; set active and standby temps to zero
M140 S-276 ; turn off bed
M291 P"Process complete" R"Done!" S1 T3
