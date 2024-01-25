; enable / disable bed soaking
M291 P"Enable bed soaking?" R"Soak?" S4 K{"Yes", "No",}  J1
set global.SoakBed = {input = 0 ? true: false}
echo "Bed soaking " ^ {global.SoakBed = true ? "enabled" : "disabled"}
