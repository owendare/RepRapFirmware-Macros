;0:/sys/checklimits.;
; used to ensure print isn't outside bed limits
; requires paramaters A,B,C,D be sent from slicer
if (!exists(param.A)) || (!exists(param.B)) || (!exists(param.C)) || (!exists(param.D)) || (!exists(param.E))
	abort "Limits check macro called with no parameters"

if (param.A < move.axes[0].min) || (param.B > move.axes[0].max) || (param.C < move.axes[1].min) || (param.D > move.axes[1].max) || (param.E > move.axes[2].max)
	abort "Print moves outside bed limits - print aborted"