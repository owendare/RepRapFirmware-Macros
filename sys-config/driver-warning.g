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

echo " A driver warning has occured on driver " ^ param.D
echo param.S
echo "Layer shifting may have occured at " ^ move.axes[2].machinePosition ^ "mm"

if var.tempSensor = -1
	echo "No driver temp sensor configured.  Cannot report temps."
	echo "No further action taken"
	M99
	
echo "Driver temp = " ^ var.lastTemp
if var.lastTemp >= 100
	echo "Driver " ^  param.D ^ " reports over temperature : " ^ var.lastTemp ^ " C"
	if job.file.fileName!=null
		echo "Pausing print due to driver over temp warning"
		M25
	else
		M400 ; wait for current move to stop
		M18 ; turn off all drivers
else
	echo "Driver " ^  param.D ^ " reports temp OK : " ^ var.lastTemp ^ " C"
