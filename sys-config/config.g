; Configuration file for Duet WiFi (firmware version 3)
; executed by the firmware on start-up
;
; this config.g is for reference only
; you should generate a file for your printer using the online configuration tool and modify that as required using these examples
; https://configtool.reprapfirmware.org/Start

M81 C"pson" ; define the pson pin as power control and set to off by default



; Global variable to run/not run daemon.g - checked in daemon.g and abort if false
if !exists(global.RunDaemon)
	global RunDaemon = true  
else
	set global.RunDaemon = true 

; Global variable to run/not run heater checks daemon.g - checked in daemon.g and abort if false
if !exists(global.RunHeaterChecks)
	global RunHeaterChecks = true  
else
	set global.RunHeaterChecks = true

if !exists(global.Cancelled)  ; global variable for exiting out of loops
	global Cancelled = false  
else
	set global.Cancelled = false 

if !exists(global.filamentDistance)
	global filamentDistance = 0 ; global for use to allow filament to feed for set distance after sensor trips 
else
	set global.filamentDistance = 0
	
; serial comms / Paneldue
M575 P1 B57600 S1
; General preferences
G90                                                         ; send absolute coordinates...
M83                                                         ; ...but relative extruder moves
M550 P"3Dprinter"                                       	; set printer name

; Network
M554 P192.168.1.1											; set gateway
M553 P255.255.255.0											; set netmask
M552 S1 P"DARE"                                             ; enable network
M586 P0 S1                                                  ; enable HTTP
M586 P1 S1                                                  ; enable FTP
M586 P2 S1                                                  ; enable Telnet

; Drives
M569 P0 S1                                                  ; physical drive 0 (X) goes forwards
M569 P1 S0                                                  ; physical drive 1 (Y) goes backwards
M569 P2 S1                                                  ; physical drive 2 (Z) goes forwards
M569 P3 S0                                                  ; physical drive 3 (E0) goes backwards
M584 X0 Y1 Z2:4 E3											; two Z motors connected to driver outputs Z and E1
M671 X-74:240 Y79:79 S5.5 									; leadscrews at left (connected to Z) and right (connected to E1) of X axis
M350 X16 Y16 Z16 I1                           				; Configure microstepping with interpolation for XYZ
M350 E16 I1													; Configure microstepping with interpolation for E0
M92 X100.00 Y100.00 Z400.00                            		; set steps per mm XYZ
M92 E854										; set E steps/mm for Titan Aero

; axis settings
M98 P"0:/sys/set_max_speeds.g" ; set all the max speeds in macro as these are adjusted during home moves so we only want to adjust in one spot
M906 X1100 Y1100 Z1100 E1400 I30                             ; set motor currents (mA) and motor idle factor in per cent
M84 S600                                                     ; Set idle timeout at 10 minute

; Axis Limits
M208 X0:215 Y-2:200 Z0:180 									; X carriage moves from 0 to 200, Y bed goes from -2 to 200

; Endstops
M574 X1 S1 P"xstop"                                         ; configure active-high endstop for low end on X via pin xstop
M574 Y1 S1 P"ystop"                                         ; configure active-high endstop for low end on Y via pin ystop
M574 Z1 S2                                                  ; configure Z-probe endstop for low end on Z

; Z-Probe
M950 S0 C"exp.heater3"                                      ; create servo pin 0 for BLTouch
M558 P9 C"^zprobe.in" H6 F600:120 T4800 A10 S0.03 R0.5 B1         ; set Z probe type to bltouch and the dive height + speeds - turn off heaters when probing
G31 P500 X26.2 Y-1 Z0.96                                  	; set Z probe trigger value, offset and trigger height
M557 X30:200 Y10:180 S30                                    ; define mesh grid

;Calculate bed centre
if !exists(global.Bed_Center_X)
	global Bed_Center_X = floor(move.axes[0].max / 2)
if !exists(global.Bed_Center_Y)
	global Bed_Center_Y = floor(move.axes[1].max  / 2)

; Heaters
M308 S0 P"bedtemp" Y"thermistor" A"Bed"  B3950 C7.06e-8         		; configure sensor 0 as thermistor on pin bedtemp
M950 H0 C"bedheat" T0 Q10                                       ; create bed heater output on bedheat and map it to sensor 0 and set PWM frequency to 10hz
M140 H0 																		; Set bed themp to zero
M143 H0 S130 A0 C0                                          ; set temperature limit for heater 0 to 130C - fault if too high
M308 S1 P"e0temp" A"Nozzle-1" Y"thermistor" T100000 B3950 C0 ; configure sensor 1 as thermistor on pin e0temp - Aurarum cartrdge thermistor
M950 H1 C"e0heat" T1                                        ; create nozzle heater output on e0heat and map it to sensor 1
M143 H1 S300 A0 C0                                          ; set temperature limit for heater 1 to 300C - fault if too high
;echo "sensor create time: " ^ state.upTime ^ "." ^ state.msUpTime


; Set PID autotune parameters
M307 H0 R0.553 C379.7 D21.16 S0.80 B0 V0
M307 H1 B0 R1.594 C358.1:217.5 D6.05 S1.00 V24.3			;set PID values for heater 1 (hotend)


; Joystick
M308 S3 P"exp.thermistor4" Y"linear-analog" A"JoyStick-X" F1 B100 C-100 ; set analog input on E3 Temp with min/max of -100 to 100
M308 S4 P"exp.thermistor6" Y"linear-analog" A"JoyStick-Y" F1 B100 C-100 ; set analog input on E5 Temp with min/max of -100 to 100
M581 T7 P7 ; set up trigger for GpIn 7
M950 J7 C"!^exp.31" 										; Input 7 uses Expansion 31 pin activate pullup and inverted


; Servos and input/output
M950 P5 C"exp.e5_stop" 										; Output 5 uses E5_STOP  pin
M950 J6 C"exp.e6_stop" 										; Input 6 uses E6_STOP  pin


; Filament monitor
M591 P1 C"e0stop" S1 D0 									; filament monitor for extruder 0 connected to E0 endstop

; Fans
M950 F0 C"fan0" Q50                                        ; create fan 0 on pin fan0 and set its frequency
M106 P0 C"Part_Fan" S0 B2.0 H-1                             ; set fan 0 name and value. Thermostatic control is turned off
																; Adjust MCU temp reading to match ambient

;water pump
M950 F1 C"!fan1+^exp.pb6" Q25000                             ; create fan 1 (water pump) on inverted pin fan1 and set its frequency.  Set RPM to E3 stop with pullup enabled
M106 P1 C"Water Pump" H1 L0.5 X1 B1.2  T50:60                       ; set fan 1 name and value. Thermostatic control is turned on.  Monitoring hoted sensor

; water temp monitor & fan
M950 F2 C"!fan2+^exp.e3_stop" Q25000                                        ; create fan 2 on pin fan2 and set its frequency
M308 S5 P"e1temp" Y"thermistor" A"Water temp" T10000 B3950  					; Configure Water temp sensor
M106 P2 C"Radiator Fan" H5 L0 X1 B1.2  T33:38    	; set fan 4 value, turn on at 30% if the water temperature reaches 30C, and increase to full speed gradually as the temperature rises to 40C

; MCU temp sensor
M308 S2 P"mcu-temp" Y"mcu-temp" A"Duet Board" 					; Configure MCU sensor
; Calibrate MCU temp
M912 P0 S-4	

; Tools
M563 P0 S"Extruder1" D0 H1 F0                               ; define tool 0
G10 P0 X0 Y0 Z0                                             ; set tool 0 axis offsets
;Select tool zero
;T0 P0 ; select tool zero but don't run any tool change macros

T0 ; select tool

; Global Variables for heater checking routine in daemon.g

if !exists(global.HeaterCheckInterval)
	global HeaterCheckInterval=6 ; variable for use in daemon.g sets interval of heater checks
else
	set global.HeaterCheckInterval=6 ; variable for use in daemon.g sets interval of heater checks


while heat.heaters[1].current=2000 ; loop until thermistor values are stable
	G4 P1
	if iterations > 10000 ; if it takes more than 10 seconds we have a problem with the thermistor
		M118 P0 L1 S"Thermistor failed to stabilize in less than 10 seconds"
		break
;echo "sensor stable time: " ^ state.upTime ^ "." ^ state.msUpTime

if !exists(global.LastTemp) || global.LastTemp=null
	global LastTemp=heat.heaters[1].current ; Set variable to current extruder temp.
else
	set global.LastTemp=heat.heaters[1].current ; Set variable to current extruder temp.
G4 P10
if !exists(global.LastCheckTime)
	global LastCheckTime=0 ; variable for use in daemon.g 
else
	set global.LastCheckTime=0 ; variable for use in daemon.g

if !exists(global.BedPreheatTemp)
	global BedPreheatTemp=0 ; variable for use in preheating 
else
	set global.BedPreheatTemp=0 ; variable for use in preheating 


; extrusion
if !exists(global.LoadedFilament) || global.LoadedFilament=null; global variable to hold filament name
	global LoadedFilament="No_Filament" ; create a filament variable
G4 P10
if move.extruders[state.currentTool].filament=""
	echo "No filament loaded.  Cold extrude & retract set to defaults"
	M302 S190 R110 ; Allow extrusion starting from 190°C and retractions already from 110°C (defaults)
	set global.LoadedFilament="No_Filament"
else
	set global.LoadedFilament=move.extruders[state.currentTool].filament ; set the variable to the currently loaded filament
	echo "Loading config for " ^ global.LoadedFilament ^ " filament"
	M703 ; if a filament is loaded, set all the heats and speeds for it by loading config.g
G4 P10



; Custom settings
M376 H4   ; set bed compensation taper (H4 means taper over 4mm)

; Power failure recovery
M911 S22.5 R23.0 P"M42 P5 S0 M106 P0 S0 M913 X0 Y0 G91 M83 G1 Z3 E-2 F1000" ; If power drops below 22v then turn off fans, Set X & Y current to zero, raise head, retract.

; turn on LED strip driven by P5 output
M42 P5 S1

;Valve Control test to control servo position via fan speed
; Set up scaling variables {(output_end - output_start) / (input_end - input_start)}
;M950 S1 C"exp.heater4"  ; assign GPIO port 0 to heater4 on expansion connector, servo mode
if !exists(global.InputStart) || global.InputStart=null
	global InputStart=0
else 
	set global.InputStart=0
G4 P10
if !exists(global.InputEnd) || global.InputEnd=null
	global InputEnd=1
else
	set global.InputEnd=1
G4 P10
if !exists(global.OutputStart) || global.OutputStart=null
	global OutputStart=0
else
	set global.OutputStart=0
G4 P10
if !exists(global.OutputEnd) || global.OutputEnd=null
	global OutputEnd=180
else
	set global.OutputEnd=180
G4 P10
if !exists(global.ScaleFactor) || global.ScaleFactor=null
	global ScaleFactor=(global.OutputEnd - global.OutputStart) / (global.InputEnd - global.InputStart) ; no need for the math in this instance but it makes it clear how you arrive at the value.
else
	set global.ScaleFactor=(global.OutputEnd - global.OutputStart) / (global.InputEnd - global.InputStart)
G4 P10
if !exists(global.ServoOut) || global.ServoOut=null
	global ServoOut=floor(global.ScaleFactor * (fans[0].actualValue - global.InputStart) + 0.5) + global.OutputStart ; calculate position required on sevo - use floor to apply rounding
else
	set global.ServoOut=floor(global.ScaleFactor * (fans[0].actualValue - global.InputStart) + 0.5) + global.OutputStart
;M280 P1 S{global.servo_out} ; adjust valve position to reflect fan speed.

;play startup tune
G4 S8					; Allow time for PanelDue to start & wifi connection etc
M98 P"0:/macros/songs/itchyscratchy.g"								; Play tune
M501 ; load config-overide.g


; configure accelerometer
M955 P0 I06  R10 S2000 Q2000000 C"spi.cs3+spi.cs4" ; configure accelerometer
M568 P0 R0 S0 A0 ; set heater on T0 to off


