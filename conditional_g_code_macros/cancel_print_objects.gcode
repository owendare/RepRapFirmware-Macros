if !{state.status="processing"} 
	M291 P"Not printing" R"Error" S1 T7
	abort "Not printing"
if {job.layer<2}
	M291 P"Not all objects may be detected yet.  Continue?" R"Warning" S3
	G4 S0.5
if {(#job.build.objects=null) || (#job.build.objects=0)}
	M291 P"No objects detected.  Check slicer or wait till end of first layer" R"Error" S2
	;abort "No objects"
;if {(job.build.currentObject=null) || (job.build.currentObject=-1)}
;	M291 P"Current print move is not a print object" R"Not a print object" S2
;	abort "not a print object"
echo #job.build.objects
while iterations  < #job.build.objects
	echo "check object " ^ iterations + 1
	if job.build.objects[ iterations ].cancelled
		echo "Obect " ^ iterations ^ "already cancelled"
		G4 S1
		continue
	M291 P{(job.build.objects[iterations].name)} R"Delete?" S3
	M486 P{iterations}
	G4 S1
echo "Finished"