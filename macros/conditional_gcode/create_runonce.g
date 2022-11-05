; create_runonce.g - creates a file that is run after config.g is run and network is enabled
echo >"0:/sys/runonce.g" "G4 S20 ; give the network time to establish connection"
echo >>"0:/sys/runonce.g" "if network.interfaces[0].state != ""active"""
echo >>"0:/sys/runonce.g" "  M552 S0           ; disable networking"
echo >>"0:/sys/runonce.g" "  M291 R""Network check""  P""Disable networking"" S0 T3"
echo >>"0:/sys/runonce.g" "else"
echo >>"0:/sys/runonce.g" "  M291 R""Network check""  P""Network active"" S0 T3"