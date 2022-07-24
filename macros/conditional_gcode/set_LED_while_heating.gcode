; set_LED_while_heating.g

while heat.heaters[1].current < 120
    M98 P"set_led_by_temp.gcode"
    G4 S3
; done heating, so set to white
M150 R255 U255 B255 W255 P255 F0 ; set pixels