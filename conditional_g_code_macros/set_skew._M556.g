; set_skew_M556.g
; calculate the skew values based on diagonal measurements of a test object
;  https://www.thingiverse.com/thing:2972743/comments
; Mark the test point corners A,B,C,D as per the diagram below
; MEASUREMENTS SHOULD ONLY BE TAKEN ON A MODEL PRINTED WITH NO SKEW ADJUSTMENTS IN PLACE
; computation formulae from Marlin firmware
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

;check to see if any skew adjustments are active.  Measurements may be invalid if object was printed with active skew adjustment
if (move.compensation.skew.tanXY != 0) || (move.compensation.skew.tanXZ != 0) || (move.compensation.skew.tanYZ  != 0)
	M291 S3 P"M556 adjustments in place" R"There are skew adjustments in place.  Ensure object being measured was printed without adjustments.  Proceed?"
	
var xySkew = 0
var xzSkew = 0
var yzSkew = 0

M291 S3 P"Measure X-Y Skew?" R"Measure X-Y"
G4 P200
; Maximum size limited to whichever axis is smallest
var max = min(move.axes[0].max,move.axes[1].max,move.axes[2].max)

M291 S6 P{"Enter side length of square (mm) max = " ^ var.max} R"Square" L10 H{var.max} F100.00 J1
var calculatedDiagonal = sqrt((input*input) + (input*input))
var A_D = input
var x2 = move.axes[0].max * move.axes[0].max
var y2 = move.axes[1].max * move.axes[1].max
; limit the diagonal to teh max possible iin the print volume
var maxDiagonal = sqrt(var.y2 + var.x2)

M291 S6 P"Enter A -> C measurement" R"A -> C"  R"X -> Y"  F{var.calculatedDiagonal} L10.0 H{var.maxDiagonal} J1
var A_C = input
; calculate area of rhombus given one side and diagonal
; 1/2 var.A_D sqrt(4*var.A_D*var.A_D)  - var.A_C * var.A_C
var area = 1/2* var.A_C * sqrt(4 * var.A_D * var.A_D  - var.A_C * var.A_C)
echo "Area = " ^ var.area
var difXY =  (var.area / var.A_C) * 2 ; calculates second diagonal of a rhombus given length of first
M291 S6 P"Enter B -> D measurement" R"B -> D" R"X -> Y" F{var.difXY} L10.0 H{var.maxDiagonal} J1
var B_D = input
var A_B = sqrt((2 * var.A_C * var.A_C) + (2 * var.B_D * var.B_D) - (4 * var.A_D * var.A_D))/2
set var.xySkew = tan(pi/2-acos((var.A_C*var.A_C-var.A_B*var.A_B-var.A_D*var.A_D)/(2*var.A_B*var.A_D)))

G4 P200
echo "Set M556 for X-Y Skew to M556 S1 X" ^ var.xySkew ^ " Ynn Znn"
G4 P200
M291 S4 P{"Apply skew (" ^ var.xySkew ^ ") to X-Y?"} R"Apply?" K{"Yes","No"} F0 J1 
if input = 0
	M556 S1 X{var.xySkew}

G4 P200

; move to X Z 
M291 S3 P"Continue to X-Z Skew?" R"Measure X-Z"
G4 P200
M291 S6 P"Enter A -> C measurement" R"A -> C" R"X -> Z" F{var.calculatedDiagonal} L10.0 H{var.maxDiagonal} J1
set var.A_C = input
set var.area = 1/2* var.A_C * sqrt(4 * var.A_D * var.A_D  - var.A_C * var.A_C)
var difXZ =  (var.area / var.A_C) * 2 ; calculates second diagonal of a rhombus given length of first
echo var.difXZ
M291 S6 P"Enter B -> D measurement" R"B -> D" R"X -> Z" F{var.difXZ} L10.0 H{var.maxDiagonal} J1
set var.B_D = input
set var.A_B = sqrt((2 * var.A_C * var.A_C) + (2 * var.B_D * var.B_D) - (4 * var.A_D * var.A_D))/2
set var.xzSkew = tan(pi/2-acos((var.A_C*var.A_C-var.A_B*var.A_B-var.A_D*var.A_D)/(2*var.A_B*var.A_D)))
echo "Set M556 for X-Z skew to M556 S1 Xnn Ynn Z"^ var.xzSkew 
G4 P200
M291 S4 P{"Apply Skew (" ^var.xzSkew ^ ") to X-Z?"} R"Apply?" K{"Yes","No"} F0 J1 
if input = 0
	M556 S1 Z{var.xzSkew}

G4 P200

; move to Y Z 
M291 S3 P"Continue to Y-Z Skew?" R"Measure Y-Z"
G4 P200
M291 S6 P"Enter A -> C measurement" R"A -> C" R"Y -> Z" F{var.calculatedDiagonal} L10.0 H{var.maxDiagonal} J1
set var.A_C = input
set var.area = 1/2* var.A_C * sqrt(4 * var.A_D * var.A_D  - var.A_C * var.A_C)
var difYZ =  var.area / var.A_C * 2
echo var.difYZ
M291 S6 P"Enter B -> D measurement" R"B -> D" R"Y -> Z" F{var.difYZ} L10.0 H{var.maxDiagonal} J1
set var.B_D = input
set var.A_B = sqrt((2 * var.A_C * var.A_C) + (2 * var.B_D * var.B_D) - (4 * var.A_D * var.A_D))/2
set var.yzSkew = tan(pi/2-acos((var.A_C*var.A_C-var.A_B*var.A_B-var.A_D*var.A_D)/(2*var.A_B*var.A_D)))
echo "Set M556 for Y-Z skew to M556 S1 Xnn Y" ^ var.yzSkew ^ " Znn" 
M291 S4 P{"Apply skew (" ^var.yzSkew ^ ") to Y-Z?"} R"Apply?" K{"Yes","No"} F0 J1 
if input = 0
	M556 S1 Y{var.yzSkew}


if (move.compensation.skew.tanXY != var.xySkew) || (move.compensation.skew.tanXZ != var.xzSkew) || (move.compensation.skew.tanYZ  != var.yzSkew)
	echo "Calculated skew settings should be:" 
	echo "M556 S1 X" ^ {var.xySkew}^ " Y" ^ {var.yzSkew} ^ " Z" ^ {var.xzSkew}
	echo "Actual setting"
	M556
	M291 S4 P{"One or more skew settings has not been applied - Apply Now?"} R"Settings not applied?" K{"Yes","No"} F0 J1 
	if input = 0
		M556 S1 X{var.xySkew} Y{var.yzSkew}	Z{var.xzSkew}
		M556
M291 S1 T10 P"Review results in console or send M556 to confirm" R"Done"
