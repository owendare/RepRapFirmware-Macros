; Trigger7.g   Used to jog carriqage via attached joystick.
G4 P10 ; delay 10ms to debounce
if sensors.gpIn[7].value=0
	M99 ; break out if sensor value is zero again (bouncing)
	
if job.file.fileName!=null
	echo "Print loaded... Cannot jog carriage"
	M99 ; cancel macro

if move.axes[0].homed!=true || move.axes[1].homed!=true || move.axes[2].homed!=true
	echo "Insufficient axes homed... macro cancelled"
	M99

while sensors.gpIn[7].value=1
	if sensors.analog[3].lastReading <= -2 ; lower X
		if sensors.analog[3].lastReading <= -2 && sensors.analog[4].lastReading <= -2 ; lower X & Y
			G1 X{move.axes[0].machinePosition-abs(sensors.analog[3].lastReading*0.02)} Y{move.axes[1].machinePosition-abs(sensors.analog[4].lastReading*0.02)} F{abs(sensors.analog[3].lastReading*20)} ;
		elif sensors.analog[3].lastReading <= -2 && sensors.analog[4].lastReading >= 2 ; lower X & Higher Y
			G1 X{move.axes[0].machinePosition-abs(sensors.analog[3].lastReading*0.02)} Y{move.axes[1].machinePosition+abs(sensors.analog[4].lastReading*0.02)} F{abs(sensors.analog[3].lastReading*20)} ;
		else 
			G1 X{move.axes[0].machinePosition-abs(sensors.analog[3].lastReading*0.02)} F{abs(sensors.analog[3].lastReading*20)} ; just lower X

	if sensors.analog[4].lastReading <= -2 ; lower Y
		if sensors.analog[3].lastReading >= 2 && sensors.analog[4].lastReading <= -2 ; lower Y & Higher X
			G1 X{move.axes[0].machinePosition+abs(sensors.analog[3].lastReading*0.02)} Y{move.axes[1].machinePosition-abs(sensors.analog[4].lastReading*0.02)} F{abs(sensors.analog[3].lastReading*20)} ;
		else
			G1 Y{move.axes[1].machinePosition-abs(sensors.analog[4].lastReading*0.02)} F{abs(sensors.analog[4].lastReading*20)} ; lower Y only

	if sensors.analog[3].lastReading >= 2 ; higher X
		if  sensors.analog[4].lastReading >= 2 ;higher X & Y
			G1 X{move.axes[0].machinePosition+abs(sensors.analog[3].lastReading*0.02)} Y{move.axes[1].machinePosition+abs(sensors.analog[4].lastReading*0.02)} F{abs(sensors.analog[3].lastReading)*20}
		elif sensors.analog[3].lastReading >= 2 && sensors.analog[4].lastReading > -2 && sensors.analog[4].lastReading < 2 ; higher X & Y is zero +/- 5
			G1 X{move.axes[0].machinePosition+(sensors.analog[3].lastReading*0.02)} F{abs(sensors.analog[3].lastReading*20)} ; 

	if sensors.analog[4].lastReading >= 5 && sensors.analog[3].lastReading < 5 && sensors.analog[3].lastReading > -5 ; higher Y & X is zero +/- 5
		G1 Y{move.axes[1].machinePosition+(sensors.analog[4].lastReading*0.02)} F{abs(sensors.analog[4].lastReading*20)} ;
	M400