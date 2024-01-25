;set_temp.g
; can be called with the paramters S=ActiveTemp, R=StandbyTemp, H=WhichHeater
; e.g  M98 P"0:/macros/set_temp.g" S220 R100 H0
; alternately set the temps manually in the variables
var WhichHeater = 0 ; Assuming we have one heater per tool, we will be looking at heater zero
var StandbyTemp = 40 ; change to suit your needs if not called using parameters
var ActiveTemp = 100 ; change to suit your needs if not called using parameters

; check to see if we've called this from another fileusing parameters
if exists(param.S)
	set var.ActiveTemp = param.S	
if exists(param.R)
	set var.StandbyTemp = param.R
if exists(param.H)
	set var.WhichHeater = param.H

if state.currentTool = -1
	M291 P"Press OK to use tool zero (T0) or cancel to abort" R"No tool selected" S3 ; make sure a tool is selected
	T0 P0 ;  select tool zero but don't run tool change files
if (var.WhichHeater >= #tools[state.currentTool].heaters) || (var.WhichHeater<0) ; sanity check on the heater number
	set var.WhichHeater = 0
	echo "Invalid heater number was supplied - reset to zero"
if var.StandbyTemp > var.ActiveTemp ; sanity check temps
	set var.StandbyTemp = var.ActiveTemp ; if standby was higher than active we reset them the same
	echo "standby temp was set higher than active temp - resetting both  to same temp"
var CurrentState = heat.heaters[tools[state.currentTool].heaters[var.WhichHeater]].state ; assumes only one heater per tool
if var.CurrentState= "off"
	M568 T{state.currentTool} S{var.ActiveTemp} R{var.StandbyTemp} A0
	echo "Tool " ^ state.currentTool ^ " temps set to " ^ var.ActiveTemp ^ "/" ^ var.StandbyTemp ^ " : State is : " ^ var.CurrentState
elif var.CurrentState = "standby"
	M568 T{state.currentTool} S{var.ActiveTemp} R{var.StandbyTemp} A1
	echo "Tool " ^ state.currentTool ^ " temps set to " ^ var.ActiveTemp ^ "/" ^ var.StandbyTemp ^ " : State is : " ^ var.CurrentState
elif var.CurrentState = "active"
	M568 T{state.currentTool} S{var.ActiveTemp} R{var.StandbyTemp} A2
	echo "Tool " ^ state.currentTool ^ " temps set to " ^ var.ActiveTemp ^ "/" ^ var.StandbyTemp ^ " : State is : " ^ var.CurrentState
else
	echo "Heater state reported is := " ^ var.CurrentState ; if we got to here then we either made a typo or the heater state in "tuning" or in an error state
	echo "cannot set temps in this state"	
