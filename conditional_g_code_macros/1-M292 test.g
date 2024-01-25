while iterations < 5
	G4 S2
	M291 S3 P{"Testing Break " ^ iterations} R"Test" T5
	G4 S2
	echo "After iteration " ^ iterations

while iterations < 5
	G4 S2
	M291 S3 P{"Testing Continue " ^ iterations} R"Test" T5
	G4 S2
	echo "After iteration " ^ iterations

echo "finished"
