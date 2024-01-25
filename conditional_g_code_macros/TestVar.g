var count = 0
while var.count < 3
  echo "Hello world. Count:  ", {var.count}
  var param = 42 + var.count
  echo "Param: ", {var.param}
  set var.count = {var.count + 1} 
var param = 35
echo "Param: ", {var.param}
;end while