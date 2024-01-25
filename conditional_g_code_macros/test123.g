M291 P"Start" R"Ready to start" S2
set global.macroPause = true
while global.macroPause = true
	G4 S5
echo "done"
set global.macroPause = false
