; File "0:/gcodes/Shape-Box_0.2mm_ABS.gcode" resume print after print paused at 2021-12-06 14:21
G21
M140 P0 S105.0
G29 S1
T-1 P0
G92 X88.773 Y80.122 Z16.660
G60 S1
G10 P0 S270 R215
T0 P0
M98 P"resurrect-prologue.g"
M116
M290 X0.000 Y0.000 Z0.000 R0
T-1 P0
T0 P6
; Workplace coordinates
G10 L2 P1 X0.00 Y0.00 Z0.00
G10 L2 P2 X0.00 Y0.00 Z0.00
G10 L2 P3 X0.00 Y0.00 Z0.00
G10 L2 P4 X0.00 Y0.00 Z0.00
G10 L2 P5 X0.00 Y0.00 Z0.00
G10 L2 P6 X0.00 Y0.00 Z0.00
G10 L2 P7 X0.00 Y0.00 Z0.00
G10 L2 P8 X0.00 Y0.00 Z0.00
G10 L2 P9 X0.00 Y0.00 Z0.00
G54
M106 S0.30
M106 P0 S0.30
M116
G92 E0.00000
M83
M486 S0 A"Shape-Box id:0 copy 0"
M486 S-1
G17
M23 "0:/gcodes/Shape-Box_0.2mm_ABS.gcode"
M26 S89056
G0 F6000 Z18.660
G0 F6000 X88.773 Y80.122
G0 F6000 Z16.660
G1 F1350.0 P0
G21
M24
