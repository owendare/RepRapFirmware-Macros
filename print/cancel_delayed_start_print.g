; simply sets blobal.Cacenellec to true.
; delayed start checks for this and aborts.
if !exists(global.Cancelled)
   global.Cancelled = true
else
   set global.Cancelled = true
echo"global.Cancelled set to true.  Delayed start will abort in a short while.  Please wait"