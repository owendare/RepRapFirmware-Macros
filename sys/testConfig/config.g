; Configuration file for Duet WiFi (firmware version 3.3)
; executed by the firmware on start-up
;
; generated by RepRapFirmware Configuration Tool v3.3.16 on Sat Apr 01 2023 08:00:33 GMT+1000 (Australian Eastern Standard Time)

; General preferences
; serial comms / Paneldue
M575 P1 B57600 S1
; General preferences
G90                                                         ; send absolute coordinates...
M83                                                         ; ...but relative extruder moves
M550 P"3Dprinter"                                       	; set printer name

; Network
M586 P0 S1                                                  ; enable HTTP
M586 P1 S1                                                  ; enable FTP
M586 P2 S1                                                  ; enable Telnet
M554 P192.168.1.1											; set gateway
M553 P255.255.255.0											; set netmask
M552 S1 P"DARE"                                         ; disable Telnet

M81 C"pson" 
; Drives
M569 P0 S1                                         ; physical drive 0 goes forwards
M569 P1 S1                                         ; physical drive 1 goes forwards
M569 P2 S1                                         ; physical drive 2 goes forwards
M569 P3 S1                                         ; physical drive 3 goes forwards
M569 P4 S1                                         ; physical drive 4 goes forwards
M584 X0 Y1 Z2 E3:4                                 ; set drive mapping
M350 X16 Y16 Z16 E16:16 I1                         ; configure microstepping with interpolation
M92 X80.00 Y80.00 Z400.00 E420.00:420.00           ; set steps per mm
M566 X900.00 Y900.00 Z60.00 E120.00:120.00         ; set maximum instantaneous speed changes (mm/min)
M203 X6000.00 Y6000.00 Z180.00 E1200.00:1200.00    ; set maximum speeds (mm/min)
M201 X500.00 Y500.00 Z20.00 E250.00:250.00         ; set accelerations (mm/s^2)
M906 X800 Y800 Z800 E800:800 I30                   ; set motor currents (mA) and motor idle factor in per cent
M84 S30                                            ; Set idle timeout

; Axis Limits
M208 X0 Y0 Z0 S1                                   ; set axis minima
M208 X230 Y210 Z200 S0                             ; set axis maxima

; Endstops
M574 X1 S1 P"xstop"                                ; configure switch-type (e.g. microswitch) endstop for low end on X via pin xstop
M574 Y1 S1 P"ystop"                                ; configure switch-type (e.g. microswitch) endstop for low end on Y via pin ystop
M574 Z1 S2                                         ; configure Z-probe endstop for low end on Z

; Z-Probe
M558 P1 C"zprobe.in" H5 F120 T6000                 ; set Z probe type to unmodulated and the dive height + speeds
G31 P500 X0 Y0 Z2.5                                ; set Z probe trigger value, offset and trigger height
M557 X15:215 Y15:195 S20                           ; define mesh grid

; Heaters
M308 S0 P"bedtemp" Y"thermistor" T100000 B4138     ; configure sensor 0 as thermistor on pin bedtemp
M950 H0 C"bedheat" T0                              ; create bed heater output on bedheat and map it to sensor 0
M307 H0 B0 S1.00                                   ; disable bang-bang mode for the bed heater and set PWM limit
M140 H0                                            ; map heated bed to heater 0
M143 H0 S120                                       ; set temperature limit for heater 0 to 120C
M308 S1 P"e0temp" Y"thermistor" T100000 B4138      ; configure sensor 1 as thermistor on pin e0temp
M950 H1 C"e0heat" T1                               ; create nozzle heater output on e0heat and map it to sensor 1
M307 H1 B0 S1.00                                   ; disable bang-bang mode for heater  and set PWM limit
M143 H1 S280                                       ; set temperature limit for heater 1 to 280C
M308 S2 P"e1temp" Y"thermistor" T100000 B4138      ; configure sensor 2 as thermistor on pin e1temp
M950 H2 C"e1heat" T2                               ; create nozzle heater output on e1heat and map it to sensor 2
M307 H2 B0 S1.00                                   ; disable bang-bang mode for heater  and set PWM limit
M143 H2 S280                                       ; set temperature limit for heater 2 to 280C
M308 S3 P"duex.e2temp" Y"thermistor" T100000 B4138 ; configure sensor 3 as thermistor on pin duex.e2temp
M950 H3 C"duex.e2heat" T3                          ; create nozzle heater output on duex.e2heat and map it to sensor 3
M307 H3 B0 S1.00                                   ; disable bang-bang mode for heater  and set PWM limit
M143 H3 S280                                       ; set temperature limit for heater 3 to 280C
M308 S4 P"duex.e3temp" Y"thermistor" T100000 B4138 ; configure sensor 4 as thermistor on pin duex.e3temp
M950 H4 C"duex.e3heat" T4                          ; create nozzle heater output on duex.e3heat and map it to sensor 4
M307 H4 B0 S1.00                                   ; disable bang-bang mode for heater  and set PWM limit
M143 H4 S280                                       ; set temperature limit for heater 4 to 280C

; Fans
M950 F0 C"fan0" Q500                               ; create fan 0 on pin fan0 and set its frequency
M106 P0 S0 H-1                                     ; set fan 0 value. Thermostatic control is turned off
M950 F1 C"fan1" Q500                               ; create fan 1 on pin fan1 and set its frequency
M106 P1 S1 H1:2:3:4 T45                            ; set fan 1 value. Thermostatic control is turned on

; Tools
M563 P0 S"Tool 0" D0 H1:2:3 F0                     ; define tool 0
G10 P0 X0 Y0 Z0                                    ; set tool 0 axis offsets
G10 P0 R0 S0                                       ; set initial tool 0 active and standby temperatures to 0C
M563 P1 S"Tool 1" D1 H3:4:1:2 F0                   ; define tool 1
G10 P1 X0 Y0 Z0                                    ; set tool 1 axis offsets
G10 P1 R0 S0                                       ; set initial tool 1 active and standby temperatures to 0C

; Custom settings are not defined

