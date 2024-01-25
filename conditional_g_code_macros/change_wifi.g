; Add default wifi network
M291 R"Add default WIFI network? Y/N" P"This will add duet wifi access point." S3 T10
M552 S0			; Disable network module
G4 S5			; wait 5 seconds
M588 S"*" ; delete all remembered SSID's
G4 S5
M587 S"DARE_EXT" P"0413111574"			; Add duet wifi SSID to remembered networks list
G4 S5			; wait 5 seconds
M552 S1			; reenable wifi module
G4 S10