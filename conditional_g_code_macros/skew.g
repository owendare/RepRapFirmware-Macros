;    Y                     Z                     Z
;    ^     B-------C       ^     B-------C       ^     B-------C
;    |    /       /        |    /       /        |    /       /
;    |   /       /         |   /       /         |   /       /
;    |  A-------D          |  A-------D          |  A-------D
;    +-------------->X     +-------------->X     +-------------->Y
 
var AD = 180
 
var XY_AC = 265
var XY_BD = 243.67
var XY_skew_mm = 0
 
var XZ_AC = 254.558
var XZ_BD = 254.558
var XZ_skew_mm = 0
 
var YZ_AC = 254.558
var YZ_BD = 254.558
var YZ_skew_mm = 0
 
; Compute XY
var XY_AB = sqrt((2 * (var.XY_AC * var.XY_AC)) + (2 * (var.XY_BD * var.XY_BD)) - (4 * (var.AD * var.AD)))/2
var XY_skew_factor = tan(pi/2-acos((var.XY_AC * var.XY_AC - var.XY_AB * var.XY_AB - var.AD * var.AD)/(2 * var.XY_AB * var.AD)))
if (var.XY_AC-var.XY_BD>=0)
	set var.XY_skew_mm = sqrt(abs(var.XY_AB * var.XY_AB - var.AD * var.AD))
else
	set var.XY_skew_mm = -sqrt(abs(var.XY_AB * var.XY_AB - var.AD * var.AD))
 
; Compute XZ
var XZ_AB = sqrt((2 * (var.XZ_AC * var.XZ_AC)) + (2 * (var.XZ_BD * var.XZ_BD)) - (4 * (var.AD * var.AD)))/2
var XZ_skew_factor = tan(pi/2-acos((var.XZ_AC * var.XZ_AC - var.XZ_AB * var.XZ_AB - var.AD * var.AD)/(2 * var.XZ_AB * var.AD)))
if (var.XZ_AC-var.XZ_BD>=0)
	set var.XZ_skew_mm = sqrt(abs(var.XZ_AB * var.XZ_AB - var.AD * var.AD))
else
	set var.XZ_skew_mm = -sqrt(abs(var.XZ_AB * var.XZ_AB - var.AD * var.AD))
 
; Compute YZ
var YZ_AB = sqrt((2 * (var.YZ_AC * var.YZ_AC)) + (2 * (var.YZ_BD * var.YZ_BD)) - (4 * (var.AD * var.AD)))/2
var YZ_skew_factor = tan(pi/2-acos((var.YZ_AC * var.YZ_AC - var.YZ_AB * var.YZ_AB - var.AD * var.AD)/(2 * var.YZ_AB * var.AD)))
if (var.YZ_AC-var.YZ_BD>=0)
	set var.YZ_skew_mm = sqrt(abs(var.YZ_AB * var.YZ_AB - var.AD * var.AD))
else
	set var.YZ_skew_mm = -sqrt(abs(var.YZ_AB * var.YZ_AB - var.AD * var.AD))
 
echo "XY: AB ", var.XY_AB, " Skew mm " , var.XY_skew_mm, " Skew factor ", var.XY_skew_factor
echo "XZ: AB ", var.XZ_AB, " Skew mm " , var.XZ_skew_mm, " Skew factor ", var.XZ_skew_factor
echo "YZ: AB ", var.YZ_AB, " Skew mm " , var.YZ_skew_mm, " Skew factor ", var.YZ_skew_factor
 
;M556 S{var.AD} X{var.XY_skew_mm} Y{var.XZ_skew_mm} Z{var.YZ_skew_mm} 
;M556