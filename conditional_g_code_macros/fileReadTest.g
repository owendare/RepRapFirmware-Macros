var myArray = {"ABS","ASA","EDGE","eFlex","eLastic","FLEX","HIPS","NGEN","NYLON","PA-CF","PC","PCABS","PDVF","PEEK","PEI","PEKK","PET","PETG","PLA","POM","PP","PSU","PVA","SCAFF","TPE","TPU",}
var myString = ""
while iterations < #var.myArray
  set var.myString = var.myString ^ """" ^ var.myArray[iterations] ^ """" ^ ","
echo >"0:/macros/conditional_g_code_macros/myArray.csv" var.myString
var readBackArray = fileread("0:/macros/conditional_g_code_macros/myArray.csv",0,{#var.myArray},',')
echo var.readBackArray
echo var.readBackArray[0] ^ " : " ^ var.readBackArray[#var.readBackArray-1]