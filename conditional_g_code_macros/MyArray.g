;initial array
var myArray = {1,2,3,4,}
echo var.myArray

; second array one element larger
var myArray2 = vector(#var.myArray+1,null)
;copy first to second
while iterations < #var.myArray
   set var.myArray2[iterations] = var.myArray[iterations]

;set last element
set var.myArray2[#var.myArray2-1]=#var.myArray2
echo var.myArray2

;make first array bigger
set var.myArray = vector(#var.myArray+1,null)

; copy second array back into first
set var.myArray = var.myArray2
echo var.myArray