; enable / disable bed soaking
M291 P"Enable bed soaking?" R"Soak?" S4 K{"Yes", "No",}  J1
set global.BedHasSoaked = { input = 0 ? false: true}
G4 P100
echo "Bed soaking " ^ {global.BedHasSoaked = false ? "enabled" : "disabled"}
