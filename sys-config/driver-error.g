echo "Driver error: " ^ param.S

if job.file.fileName != null
	echo "Pausing print due to driver error"
	M25 ; pause print
else
	echo "No job loaded..  Turning off drivers"
	M400 ; wait for current move to stop
	M18 ; turn off all drivers