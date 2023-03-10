;macro to check bed mesh deviation
var abortNoMeshLoaded = false ; options true/false - choose whether to abort print if no mesh loaded, or just exit macro
var RMSdeviationLimit = 0.05 ; or whatever you want (use positive values)
var meanLimit = 0.003 ; or whatever you want (use positive values)

if var.RMSdeviationLimit < 0 || var.meanLimit < 0
   abort "RTFM - limits set must be positve numbers"

if move.compensation.file = null
   if var.abortNoMeshLoaded = true
      abort "No mesh loaded. Print cancelled"
   else
      echo "No mesh loaded.  Print will have no compensaton applied"
      M99

echo "checking validity of mesh: " ^ move.compensation.file
echo "Mean limit =", var.meanLimit, "RMS limit =", var.RMSdeviationLimit

var meshMean = move.compensation.meshDeviation.mean
var meshRMS = move.compensation.meshDeviation.deviation

echo "Mesh mean =", var.meshMean, "Mesh RMS =", var.meshRMS
 
if abs(var.meshRMS) > var.RMSdeviationLimit ; absolute value used to account for negative values in mesh
   abort "Mesh RMS deviation limit exceeded. Print aborted"
if abs(var.meshMean) > var.meanLimit ; absolute value used to account for negative values in mesh
   abort "Mesh mean deviation exceeded.  Print aborted"

echo "Mesh is within limits"