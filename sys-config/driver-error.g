var lastTemp=0 ; create a variable to store temp
var tempSensor = -1 ; create a variable to stor driver temp sensor
var mcuSensor = -1 ; create a variable to store MCU sensor

; find the configured driver temp sensor
while iterations < #sensors.analog  
	if sensors.analog[iterations].type = "drivers"
		set var.tempSensor = iterations ; driver temp sensor number configured by M308 in config.g
		set var.lastTemp = sensors.analog[var.tempSensor].lastReading ; last driver temp reading
		echo "sensor", iterations, "is driver temp"
	elif sensors.analog[iterations].type = "mcutemp"
		set var.mcuSensor = iterations ; MCU temp sensor number configured by M308 in config.g
		echo "sensor", iterations, "is MCU temp"
		echo "MCU temp is " ^  sensors.analog[var.mcuSensor].lastReading
		
echo "Driver error: " ^ param.S

if job.file.fileName != null
	echo "Pausing print due to driver error"
	M25 ; pause print
else
	echo "No job loaded..  Turning off drivers"
	M400 ; wait for current move to stop
	M18 ; turn off all drivers
	
if var.tempSensor = -1
	echo "No driver temp sensor configured.  Cannot report temps"
elif var.lastTemp >= 100
	echo "Driver " ^  param.D ^ " reports over temperature : " ^ var.lastTemp ^ " C"
else
	echo "Driver " ^  param.D ^ " reports temp OK : " ^ var.lastTemp ^ " C"
