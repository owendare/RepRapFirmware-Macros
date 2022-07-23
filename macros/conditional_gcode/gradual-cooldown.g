var cooltemp = {heat.heaters[0].active}
while (heat.heaters[0].active > 50) && (heat.heaters[0].current > 50) && (heat.heaters[0].state = "active")
    set var.cooltemp = var.cooltemp - 1
    echo "cooling to " ^ var.cooltemp
    M190 P0 R{var.cooltemp}
    M116 H0 S0.2
    echo "M116 complete"
    G4 S5

echo "cooldown finished"
M140 S-273
