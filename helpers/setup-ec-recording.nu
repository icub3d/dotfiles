#!/usr/bin/env nu

# Our main windows
niri msg action spawn -- kitty -d $"($nu.home-path)/dev/icub3d/everybody-codes" --title "recording-main-editor" -o font_size=18

# Our debug bar
niri msg action spawn -- kitty -d $"($nu.home-path)/dev/icub3d/everybody-codes" --title "recording-debug-bar" -o font_size=18

# Our status bar
niri msg action spawn -- kitty -d $"($nu.home-path)/dev/icub3d/everybody-codes" --title "recording-status-bar" -o font_size=18

# Our timer
niri msg action spawn -- kitty -d $"($nu.home-path)/dev/icub3d/multi-stage-timer" --title "multi-stage-speedrun-timer"

# OBS
niri msg action spawn -- obs --profile Standard --scene "Everybody Codes"
