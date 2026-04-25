#!/usr/bin/env nu
# AI Cooling Profile - Aggressive for 7900 XTX Loads

let commander_loop = "1805006373291A10"

print "Setting AI Cooling Profile..."

# Maximize Pump early
# 20C: 3500 RPM, 35C+: 4800 RPM (Max)
liquidctl set --serial $commander_loop fan6 speed 20 3500 35 4800 --temperature-sensor 1

# Aggressive Fan Curve for Water Temp 1 (Radiators)
# 30C: 800 RPM
# 35C: 1200 RPM
# 38C: 1800 RPM
# 42C: 2200 RPM (Max)
for fan in ["fan1", "fan3", "fan4", "fan5"] {
    liquidctl set --serial $commander_loop $fan speed 20 600 30 800 35 1200 38 1800 42 2200 --temperature-sensor 1
}

print "AI Cooling Profile Active."
