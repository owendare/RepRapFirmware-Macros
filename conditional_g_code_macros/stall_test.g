M291 P"Position" S5
G1 X{input} F36000
M400
if result != 0
    echo "Failed"
else
    echo "OK"