; Used to set parameters for filament such as retracts, temperatures etc
M302 S210 R130 ; set cold extrude and retract temperatures
M291 P"loading config.g for PEI" R"Loading config" S1 T5
set global.BedPreheatTemp=70 ; set be preheat variable
;M592 D0:1 A0.012 B0 ; Set non linear extrusion
M572 D0 S0.09 ;Set pressure advance
M207 S1.0 F2400  Z0	; Set retraction
;M593 F25  ; cancel ringing at 25Hz