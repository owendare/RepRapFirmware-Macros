if state.time == null
  echo "Time not set.  connect network"
  M99
echo "0:/macros/conditional_g_code_macros/" ^ "" ^ DateTime(state.time) ^ ".g" "test"
