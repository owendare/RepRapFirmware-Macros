var parameters = vector(12,null)

if exists(param.A)
    set var.parameters[0] = param.A
else
    set var.parameters[0] = "A"
if exists(param.B)
    set var.parameters[1] = param.B
else
    set var.parameters[1] = " B"
if exists(param.C)
    set var.parameters[2] = param.C
else
    set var.parameters[2] = "C"
if exists(param.D)
    set var.parameters[3] = param.D
else
    set var.parameters[3] = "D"

if exists(param.E)
    set var.parameters[4] = param.E
else
    set var.parameters[4] = "E"
    
if exists(param.F)
    set var.parameters[5] = param.F
else
    set var.parameters[5] = "F"
if exists(param.H)
    set var.parameters[6] = param.H
else
    set var.parameters[6] = "H"
if exists(param.I)
    set var.parameters[7] = param.I
else
    set var.parameters[7] = "I"
if exists(param.J)
    set var.parameters[8] = param.J
else
    set var.parameters[8] = "J"
if exists(param.K)
    set var.parameters[9] = param.K
else
    set var.parameters[9] = "K"
if exists(param.L)
    set var.parameters[10] = param.L
else
    set var.parameters[10] = "L"
if exists(param.O)
    set var.parameters[11] = param.O
else
    set var.parameters[11] = "O"

echo "Params passed were " ^ var.parameters
