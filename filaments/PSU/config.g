; Used to set parameters for filament such as retracts, temperatures etc
M291 P"loading config.g for PSU" R"Loading config" S1 T2
M302 S200 R120 ; set cold extrude and retract temperatures
set global.BedPreheatTemp=70 ; set be preheat variable
;M592 D0:1 A0.012 B0 ; Set non linear extrusion
M572 D0 S0.08 ;Set pressure advance
M207 S0.7 F2400  Z0	; Set retraction
;M593 F25  ; cancel ringing at 25Hz