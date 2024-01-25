;report filament usage
M117 {move.extruders[0].position} ^ " : " ^ {job.file.filament[0]} R"filament used"
G4 S1
echo "Done"