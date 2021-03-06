;0:/sys/set_max_speeds.g
; sets the maximum stepper speeds and accelerations.
;we do it here because we adjust it  in several macros for homing etc
; this means we can set in one place and all macros will be correct.

M566 X280.00 Y280.00 Z120.00 E3000.00                          ; set maximum instantaneous speed changes (mm/min)
M203 X12000.00 Y12000.00 Z600.00 E6000.00                  ; set maximum speeds (mm/min)
M201 X1300.00 Y1000.00 Z800.00 E3000.00                        ; set accelerations (mm/s^2)