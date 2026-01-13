#!/usr/bin/env nu

# Our main window
niri msg action spawn -- ghostty +new-window --working-directory=$"($nu.home-path)/dev/icub3d/kattis" --title="recording-vertical-main-editor" --font-size=20

# Our status bar
niri msg action spawn -- ghostty +new-window --working-directory=$"($nu.home-path)/dev/icub3d/kattis" --title="recording-vertical-status-bar" --font-size=20

# OBS
niri msg action spawn -- obs --profile Vertical --scene Vertical
