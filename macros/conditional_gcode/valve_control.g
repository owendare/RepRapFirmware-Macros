set global.ServoOut = floor((global.ScaleFactor * (fans[0].actualValue - global.InputStart)) + 0.5) + global.OutputStart ; calculate position required - use floor() to apply rounding to nearest whole number
echo {global.ServoOut}
;M280 P1 S{global.ServoOut} ; adjust valve attached to servo on P1 to reflect scaled fan speed. 