;0:/macros/SaveLastZ.g  - called at the end of print to record last used Z position
echo >"0:/macros/conditional_g_code_macros/lastZ.g" "if !exists(global.lastZ)"
echo >>"0:/macros/conditional_g_code_macros/lastZ.g" "	global lastZ=" ^ move.axes[2].userPosition
echo >>"0:/macros/conditional_g_code_macros/lastZ.g" "else"
echo >>"0:/macros/conditional_g_code_macros/lastZ.g" "	set global.lastZ=" ^ move.axes[2].userPosition