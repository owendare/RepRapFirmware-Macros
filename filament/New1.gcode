;store/update timestamp
var DaysTillNextService = 30
var SecondsTillService = var.DaysTillNextService * 60 * 60 * 24

if !exists(global.myTimeStamp)
   global myTimeStamp = state.time + var.SecondsTillService
else
   set global.myTimeStamp = state.time + var.SecondsTillService
echo >"0:/sys/maintenanceLog.g" "set global.myTimeStamp = datetime" ^ "(""" ^ global.myTimeStamp ^ """)"
echo >>"0:/sys/maintenanceLog.g" "echo ""Next maintenance due at """" ^ " ^ "datetime(" ^ """" ^ global.myTimeStamp ^ """)"""