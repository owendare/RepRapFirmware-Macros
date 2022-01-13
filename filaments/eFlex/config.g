; Used to set parameters for filament such as retracts, temperatures etc
M291 P"loading config.g for eFlex" R"Loading config" S1 T2
set global.filamentRetractSpeed = 120 ; defaults are set in /sys/config.g  - These over-ride for filaments that require slower speeds
set global.filamentFeedSpeed = 60
set global.BedPreheatTemp=40 ; set be preheat variable
M302 S205 R120 ; set cold extrude and retract temperatures
;M592 D0:1 A0.012 B0 ; Set non linear extrusion
M572 D0 S0.05 ;Set pressure advance
M207 S0.7 F2400  Z0	; Set retraction