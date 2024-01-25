; purgeOnPause.g
if global.pausePurgeActive = true
	set global.pausePurgeActive = false
	echo "Purge during pause disabled."
else
	set global.pausePurgeActive = true
	echo "Purge during pause enabled. Purge amount = " ^ global.pausePurgeAmount ^ "mm"