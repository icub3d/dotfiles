#!/usr/bin/env nu

# Our main windows
niri msg action spawn -- ghostty +new-window --working-directory=$"($nu.home-path)/dev/icub3d/advent-of-code" --title="recording-main-editor" --font-size=18

# Our debug bar
niri msg action spawn -- ghostty +new-window --working-directory=$"($nu.home-path)/dev/icub3d/advent-of-code" --title="recording-debug-bar" --font-size=18

# Our status bar
niri msg action spawn -- ghostty +new-window --working-directory=$"($nu.home-path)/dev/icub3d/advent-of-code" --title="recording-status-bar" --font-size=18

# Our timer
niri msg action spawn -- ghostty +new-window --working-directory=$"($nu.home-path)/dev/icub3d/mst" --title="multi-stage-speedrun-timer"

# OBS
niri msg action spawn -- obs --profile Standard --scene "Advent of Code"
