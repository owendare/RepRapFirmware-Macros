; prompte an error
while iterations < 10
    echo iterations
    G4 P500
   ; comment space
    if mod(iterations,2) = 0
        echo "even"
    else
        echo "odd"
    G4 P500