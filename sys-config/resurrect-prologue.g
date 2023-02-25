M98 P"0:/sys/checkATX.g"
M42 P5 S1; turn on LED strip driven by P5 output
M116 ; wait for temperatures
;M561 ; clear any bed transform 
;G29 S2 ;clear height map
;G28 XY ; home X and Y, hope that Z hasn't moved
;G1 X{global.Bed_Center_X} Y{global.Bed_Center_Y} F3600
M83 ; relative extrusion
;G11 ; undo the retraction that was done in the M911 power fail script
;M291 S3 R"Z requires homing" P"Move to safe area and hit OK" X1 Y1 ; display message to move to a place where Z can be homed.
;G30 ; Home Z 
;if result != 0
;	abort "Print cancelled due to probe error"
;G29 S1 ; load heightmap