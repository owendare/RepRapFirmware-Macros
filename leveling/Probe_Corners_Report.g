; Probe bed and report error
M561 ; clear any bed transform
; If the printer hasn't been homed, home it
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
  G28
G32
G30 P0 Z-9999
G30 P1 X{move.compensation.probeGrid.xMin} Y{move.compensation.probeGrid.yMin} Z-9999
G30 P2 X{move.compensation.probeGrid.xMin} Y{move.compensation.probeGrid.yMax} Z-9999
G30 P3 X{move.compensation.probeGrid.xMax} Y{move.compensation.probeGrid.yMax} Z-9999
G30 P4 X{move.compensation.probeGrid.xMax} Y{move.compensation.probeGrid.yMin} Z-9999 S-1