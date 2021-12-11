G29 S2 ;lear height map
M561 ; clear any bed transform
if !move.axes[0].homed || !move.axes[1].homed || !move.axes[2].homed
  G28 ; check if homing reuired and home if needed
G32 ; level both sides
M291 P"Press OK to begin" R"Check center of bed" S3 T0

G1 X{(move.axes[0].max-move.axes[0].min)/2} Y{(move.axes[1].max-move.axes[1].min)/2} Z5
G1 Z0
M291 P"Press OK to move to move to next corner" R"Check front left" S3 T0
G1 Z5
G1 X{move.axes[0].min + 10} Y{move.axes[1].min + 10} Z0
M291 P"Press OK to move to next corner" R"Check front right" S3 T0
G1 Z5
G1 X{move.axes[0].max - 10} Y{move.axes[1].min + 10} Z0
M291 P"Press OK to move to next corner" R"Check back right" S3 T0
G1 Z5
G1 X{move.axes[0].max - 10} Y{move.axes[1].max - 10} Z0
M291 P"Press OK to move to next corner" R"Check back left" S3 T0
G1 Z5
G1 X{move.axes[0].min + 10} Y{move.axes[1].max - 10} Z0
M291 P"Press OK to repeat" R"Check center of bed" S3 T0
G1 Z5
M98 P"0:/macros/leveling/level_corners.g"