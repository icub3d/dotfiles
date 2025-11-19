#!/usr/bin/env nu

# Our main window
niri msg action spawn -- kitty -d $"($nu.home-path)/dev/icub3d/kattis" --title "recording-vertical-main-editor" -o font_size=20

# Our status bar
niri msg action spawn -- kitty -d $"($nu.home-path)/dev/icub3d/kattis" --title "recording-vertical-status-bar" -o font_size=20

# OBS
niri msg action spawn -- obs --profile Vertical --scene Vertical
