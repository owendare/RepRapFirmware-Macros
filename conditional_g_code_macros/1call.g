var params = ""
set var.params = {"C24","A20","B34",}
echo "params = ", var.params
M98 P"0:/macros/conditional_g_code_macros/1receive.g" ^ {var.params}