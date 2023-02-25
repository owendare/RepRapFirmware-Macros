echo "macro started"
if (job.file.fileName=null)
	M291 P"Not printing" R"No print job is active" S1 T3
	echo "Not printing - cancelled macro"
	M99
if #job.build.objects = 0
	echo "No objects - cancel macro"
	M291 P"No objects" R"There are no objects recorded yet" S1 T3
	M99

if (job.layer=null)
	echo "Layer 1 not started yet. Macro cancelled."
	M99
	
if (job.layer = 0)
	echo "First layer not finished"
	M291 P"First layer not complete" R"Not all objects may have been recorded yet.  Continue?" S3

var objectCount = 0


while iterations < #job.build.objects
	if job.build.objects[iterations].cancelled = false
		set var.objectCount = var.objectCount + 1
echo "Found" , var.objectCount , " active objects"
var objectNames = vector(var.objectCount,null)	

var skipped = 0
while iterations < #job.build.objects
	if job.build.objects[iterations].cancelled = true
		set var.skipped = var.skipped + 1
		continue
	if (job.build.objects[iterations].name = null) || (job.build.objects[iterations].name = "")
		set var.objectNames[iterations-var.skipped] = "Object# " ^ iterations 
	else
		set var.objectNames[iterations-var.skipped] = job.build.objects[iterations].name
echo var.objectNames
M291 S4 R"Select object" P"Select object to cancel" K{var.objectNames} J1

var choice = var.objectNames[input]
echo "Choice is", var.choice
var object = -1
var thisObject = ""
while iterations < #job.build.objects
	if (job.build.objects[iterations].name = null) || (job.build.objects[iterations].name = "")
		set var.thisObject = "Object# " ^ iterations 
	else
		set var.thisObject = job.build.objects[iterations].name
	if var.choice = var.thisObject
		M486 P{iterations}