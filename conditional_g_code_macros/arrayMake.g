global bigArray = vector(30,0)
echo global.bigArray
while iterations < #global.bigArray
	set global.bigArray[iterations]=random(100)
echo global.bigArray
G4 S1
echo max(global.bigArray)