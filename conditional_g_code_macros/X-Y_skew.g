 ;  - Compute AB     : SQRT(2*AC*AC+2*BD*BD-4*AD*AD)/2
;  - XY_SKEW_FACTOR : TAN(PI/2-ACOS((AC*AC-AB*AB-AD*AD)/(2*AB*AD)))
; If desired, follow the same procedure for XZ and YZ.
;
; Use these diagrams for reference:
;
;    Y                     Z                     Z
;    ^     B-------C       ^     B-------C       ^     B-------C
;    |    /       /        |    /       /        |    /       /
;    |   /       /         |   /       /         |   /       /
;    |  A-------D          |  A-------D          |  A-------D
;    +-------------->X     +-------------->X     +-------------->Y
;     XY_SKEW_FACTOR        XZ_SKEW_FACTOR        YZ_SKEW_FACTOR
M291 S3 P"Measure X-Y Skew?" R"Measure X-Y"
M291 S6 P"Enter side length of square (mm)" R"Square" L10 H{min(move.axes[0].max,move.axes[1].max)} F100.00 J1
var calculatedDiagonal = sqrt((input*input) + (input*input))
var A_D = input
var x2 = move.axes[0].max * move.axes[0].max
var y2 = move.axes[1].max * move.axes[1].max
var maxDiagonal = sqrt(var.y2 + var.x2)
M291 S6 P"Enter A -> C measurement" R"A -> C" F{var.calculatedDiagonal} L10.0 H{var.maxDiagonal} J1
var A_C = input
M291 S6 P"Enter B -> D measurement" R"B -> D" F{var.calculatedDiagonal} L10.0 H{var.maxDiagonal} J1
var B_D = input
var A_B = sqrt((2 * var.A_C * var.A_C) + (2 * var.B_D * var.B_D) - (4 * var.A_D * var.A_D))/2
;echo var.A_B
var skew = tan(pi/2-acos((var.A_C*var.A_C-var.A_B*var.A_B-var.A_D*var.A_D)/(2*var.A_B*var.A_D)))
echo "Set M556 for X-Y skew to M556 S"^ var.A_D ^ " X" ^ var.skew ^ " Ynn Znn"
M291 S4 P"Apply skew (" ^var.skew ^ ") to X-Y?" R"Apply?" K{"Yes","No"} F0 J1 
if input = 0
	M556 S{var.A_D} X{var.skew}
; move to X Z 
M291 S3 P"Continue to X-Z Skew?" R"Measure X-Z"
M291 S6 P"Enter A -> C measurement" R"A -> C" F{var.calculatedDiagonal} L10.0 H{var.maxDiagonal} J1
;M291 S6 P"Enter A -> C measurement" R"A -> C" F{var.calculatedDiagonal} L10.0 
var A_C = input
M291 S6 P"Enter B -> D measurement" R"B -> D" F{var.calculatedDiagonal} L10.0 H{var.maxDiagonal} J1
var B_D = input
var A_B = sqrt((2 * var.A_C * var.A_C) + (2 * var.B_D * var.B_D) - (4 * var.A_D * var.A_D))/2
var skew = tan(pi/2-acos((var.A_C*var.A_C-var.A_B*var.A_B-var.A_D*var.A_D)/(2*var.A_B*var.A_D)))
echo "Set M556 for X-Z skew to M556 S"^ var.A_D ^ " Xnn Ynn Z"^ var.skew 
M291 S4 P"Apply skew (" ^var.skew ^ ") to X-Z?" R"Apply?" K{"Yes","No"} F0 J1 
if input = 0
	M556 S{var.A_D} Z{var.skew}
; move to Y Z 
M291 S3 P"Continue to X-Z Skew?" R"Measure Y-Z"
M291 S6 P"Enter A -> C measurement" R"A -> C" F{var.calculatedDiagonal} L10.0 H{var.maxDiagonal} J1
;M291 S6 P"Enter A -> C measurement" R"A -> C" F{var.calculatedDiagonal} L10.0 
var A_C = input
M291 S6 P"Enter B -> D measurement" R"B -> D" F{var.calculatedDiagonal} L10.0 H{var.maxDiagonal} J1
var B_D = input
var A_B = sqrt((2 * var.A_C * var.A_C) + (2 * var.B_D * var.B_D) - (4 * var.A_D * var.A_D))/2
var skew = tan(pi/2-acos((var.A_C*var.A_C-var.A_B*var.A_B-var.A_D*var.A_D)/(2*var.A_B*var.A_D)))
echo "Set M556 for Y-Z skew to M556 S"^ var.A_D ^ " Xnn Y" ^ var.skew ^ "Znn" 
M291 S4 P"Apply skew (" ^var.skew ^ ") to X-Z?" R"Apply?" K{"Yes","No"} F0 J1 
if input = 0
	M556 S{var.A_D} Y{var.skew}
M556