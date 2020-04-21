#!/usr/bin/fish
pacmd load-module module-alsa-sink device=hw:CARD=S7,DEV=0
pacmd load-module module-alsa-sink device=hw:CARD=S7,DEV=1
