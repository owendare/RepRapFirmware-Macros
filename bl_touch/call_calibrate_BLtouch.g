;call_calibrate_BLtouch.g
; Reprap firmware version 3.3b2 or later required!
; If macro is called using parameters these will be used in testing
; parameters which can be passed are
; T - Tool to use
; B - bed temperature to use
; R - Nozzle temperature to use (may be turned off before probing commences if configuerd to do so in config.g)
; P - probe number to use
; F -  X/Y travel speed to use (in mm/sec)
; Z - Z travel speed to use
; S - Probe speed to use (in mm/sec)
; I - Number of times to probe (high and low value will be discarded)

M98 P"0:/macros/bl_touch/calibrate_BLtouch.g" B100 T0 R240 P0 F80 Z6 S3 I12