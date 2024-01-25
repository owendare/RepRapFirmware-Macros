;0:/sys/set_max_speeds.g
; sets the maximum stepper speeds and accelerations.
;we do it here because we adjust it  in several macros for homing etc
; this means we can set in one place and all macros will be correct.

M203 X12000.00 Y12000.00 Z600.00 E12000.00                  ; set maximum speeds (mm/min)
M566 X800.00 Y800.00 Z120.00 E600.00                     ; set maximum instantaneous speed changes (mm/min)
M201 X1200.00 Y1200.00 Z600.00 E4000.00                        ; set accelerations (mm/s^2)
M913 X100 Y100 Z100 E100 ; reset all current settings to 100%