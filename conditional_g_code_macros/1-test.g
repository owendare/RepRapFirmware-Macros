M118 P3 S"Test message"
if state.time =null
    M929 P{"/sys/log/M122_Log-"^{exp(random(log(state.msUpTime))}^"-"^{random(state.msUpTime)}^".txt"} S3
else
    M929 P{"/sys/log/M122_Log"^{+state.time}^"-"^{state.msUpTime}^".txt"} S3
M122
M591 D0
M929 S0