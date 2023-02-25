;0:/sys/set_max_speeds.g
; sets the maximum stepper speeds and accelerations.
;we do it here because we adjust it  in several macros for homing etc
; this means we can set in one place and all macros will be correct.

M203 X12000.00 Y12000.00 Z600.00 E6000.00                  ; set maximum speeds (mm/min)
M566 X900.00 Y900.00 Z120.00 E3000.00                     ; set maximum instantaneous speed changes (mm/min)
M201 X1800.00 Y1400.00 Z600.00 E1200.00                        ; set accelerations (mm/s^2)
M913 X100 Y100 Z100 E100 ; reset all current settings to 100%