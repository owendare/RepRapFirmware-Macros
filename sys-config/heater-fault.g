;0:/sys/heater-fault.g - runs when heater fault detected
M291 R"Heater fault" P{"Heater fault detected on heater " ^ param.D} S0 T3
echo "Heater fault :- " ^ param.S
if (state.status=="processing") || (job.file.fileName!=null)
	echo "Pausing print"
	echo >>"0:/sys/print_log.txt" "Heater fault :- " ^ param.S
	M25 ; pause print
else
	echo "shutting down"
	echo >>"0:/sys/print_log.txt" "Heater fault :- " ^ param.S
	M0 ; shut down printer