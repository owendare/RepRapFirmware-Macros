; Untested counter kludge
; see if all files are present
M36 "0:/gcodes/003.g"
if result != 0
	; if all there do bed leveling then delete them
	;G32
	;G29 
	echo "has been run three times - do leveling"
	M30 "0:/gcodes/001.g"
	M30 "0:/gcodes.002.g"
	M30 "0:/gcodes.003.g"
else
	M36 "0:/gcodes/002.g"
		if result != 0
			M28 "0:/gcodes/003.g" ; create file
			echo "creating third file"
			M29 ; close file
		else
			M36 "0:/gcodes/001.g"
			if result != 0
				M28 "0:/gcodes/002.g" ; create file
				echo "creating second file"
				M29 ; close file
			else
				M28 "0:/gcodes/001.g" ; create file
				echo "creating first file"
				M29 ; close file
		

