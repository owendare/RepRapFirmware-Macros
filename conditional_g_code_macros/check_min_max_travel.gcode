;check min max moves
G28 ;
G1 F1800
M400
M915 X Y S3 R1
M291 P"Move to X min?" R"X Min" S3
M913 X50 Y50
G1 X{move.axes[0].min}
M913 X100 Y100
M400
M291 P"Move to X max?" R"X Max" S3
M913 X50 Y50
G1 X{move.axes[0].max}
M913 X100 Y100
M400
M291 P"Move to Y min?" R"Y Min" S3
G1 X{(move.axes[0].max-move.axes[0].min)/2}
M913 X50 Y50
G1 Y{move.axes[1].min}
M913 X100 Y100
M400
M291 P"Move to Y max?" R"Y Max" S3
M913 X50 Y50
G1 Y{move.axes[1].max}
M913 X100 Y100