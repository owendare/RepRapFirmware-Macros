; Used to set parameters for filament such as retracts, temperatures etc
M291 P"loading config.g for eLastic" R"Loading config" S1 T2
set global.filamentRetractSpeed = 120 ; defaults are set in /sys/config.g  - These over-ride for filaments that require slower speeds
set global.filamentFeedSpeed = 60
set global.BedPreheatTemp=40 ; set be preheat variable
M302 S215 R170 ; set cold extrude and retract temperatures
M572 D0 S0.05 ;Set pressure advance
M207 S0.05 F1800  Z0	; Set retraction