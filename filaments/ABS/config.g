; Used to set parameters for filament such as retracts, temperatures etc
M302 S210 R130 ; set cold extrude and retract temperatures
set global.BedPreheatTemp=90 ; set be preheat variable
M291 P"loading config.g for ABS" R"Loading config" S1 T5
M572 D0 S0.04 ;Set pressure advance
M207 S0.3 F3200  Z0	; Set retraction
;M593 F50  ; cancel ringing at 50Hz