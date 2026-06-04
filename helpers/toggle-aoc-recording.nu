#!/usr/bin/env nu

# Get all open windows from Niri
let windows = (niri msg -j windows | from json)
let rec_main = ($windows | where title == "recording-main-editor")

if ($rec_main | is-not-empty) {
    print "Closing recording layout..."
    # Target windows to close
    let titles = ["recording-main-editor" "recording-debug-bar" "recording-status-bar" "multi-stage-speedrun-timer"]
    let to_close = ($windows | where title in $titles or app_id == "com.obsproject.Studio")
    for w in $to_close {
        niri msg action close-window --id $w.id
    }
} else {
    print "Opening normal recording layout..."
    nu /home/jmarsh/dev/dotfiles/helpers/setup-aoc-recording.nu
}
