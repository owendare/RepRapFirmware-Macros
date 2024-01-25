G1 X10 F1200
G91
while iterations < 10
    G1 X10 F600
    M400
    G4 P100
    echo move.axes[0].machinePosition, ":", move.axes[0].userPosition
G92