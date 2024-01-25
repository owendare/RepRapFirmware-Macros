; 0:/macros/file_exists_check
;Check if file exists
; Send name of file to be checked as F parameter
; e.g.  M98 P"0:/macros/file_exists_check" F"0:/sys/somefile.g"
M38 {param.F} 
if result != 0
	M291 P"File doesn't exist!" R"Houston we have a problem" S0 T3
else
	M291 P"File exists."  R"Life is good" S0 T3
