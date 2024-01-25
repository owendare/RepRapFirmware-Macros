while true
  if iterations = 5
    abort "Completed"
  echo "Test # " ^ iterations + 1
  if heat.heaters[1].state="off"
   echo "State = off"
   G4 S2
   continue
  else
    echo "State = " ^ heat.heaters[1].state
    G4 S2
    continue
