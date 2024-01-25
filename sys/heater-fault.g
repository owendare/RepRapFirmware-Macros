;0:/sys/heater-fault.g - runs when heater fault detected
if state.atxPower = false ; no power to heater.  Turn it on and retry
	M291 R"Confirm" P{"Heater fault detected, but ATX is off.  Reset fault and turn on power?"} S4 K{"No","Yes",} T5 F0 J1
	if input = 1
		M80
		M562 P{param.D}
		G4 S4
		if param.D = 0
			M144 S1 ; set bad active
		else
			M568 P2 A2 ; set tool heater active
		M99
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
if param.D = 0
	set global.BedHasSoaked = false