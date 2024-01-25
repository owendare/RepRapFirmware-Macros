echo >"0:\sys\testFile.csv" "Test1,Test2,Test3,Test4,Test5"
while iterations < 5
   M400
   G1 Z5
   M400
   G30 S-1
   echo >>>"0:\sys\testFile.csv" move.axes[2].machinePosition  ^ "," 
