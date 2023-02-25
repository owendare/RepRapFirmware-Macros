; test file doing multiple non sequential tools (we won't have a T1)
M308 S4 P"exp.thermistor5" A"Nozzle-2" Y"thermistor" T100000 B3950 C0 ; configure sensor 1 as thermistor on pin e0temp - Aurarum cartrdge thermistor
M950 H4 C"exp.heater4" T2                                        ; create nozzle heater output on e0heat and map it to sensor 1
M143 H4 S285 A0 C0 
M308 S5 P"exp.thermistor7" A"Nozzle-3" Y"thermistor" T100000 B3950 C0 ; configure sensor 1 as thermistor on pin e0temp - Aurarum cartrdge thermistor
M950 H5 C"exp.heater6" T3                                        ; create nozzle heater output on e0heat and map it to sensor 1
M143 H5 S285 A0 C0 

; create some tools
M563 P2 S"dummy1" D0 H4 F0                               ; define tool 2
G10 P2 X0 Y0 Z-0.25                                             ; set tool 2 axis offsets
M563 P3 S"dummy2" D0 H5 F0                               ; define tool 3
G10 P3 X0 Y0 Z1.098                                             ; set tool 3 axis offsets