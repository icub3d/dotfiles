#!/usr/bin/env nu
# Pin USB audio devices to fixed ALSA card indices on antimond.
#
# Specific to this machine's hardware: the DP KVM / USB switcher returns
# devices on two hubs about a minute apart, so ALSA card indices rotate on
# every switch and PipeWire's stale nodes end up aimed at the wrong card.
# See helpers/alsa-card-order.conf for the full write-up.

let dotfiles = ($nu.home-dir | path join "dev/dotfiles/helpers")
let src = ($dotfiles | path join "alsa-card-order.conf")
let dest = "/etc/modprobe.d/alsa-card-order.conf"

let expected = [
    [index vid pid name];
    [3 "0b05" "1a52" "ASUSTek USB Audio"]
    [4 "046d" "085e" "Logitech BRIO"]
    [5 "1532" "0577" "Razer BlackShark V3 Pro"]
    [6 "046d" "0aaf" "Blue Microphones Yeti X"]
]

# The VID:PIDs below are this machine's. Bail out somewhere they mean nothing
# rather than pinning indices for devices that aren't here.
let usb = (lsusb | str lowercase)
let missing = ($expected | where {|r| not ($usb | str contains $"($r.vid):($r.pid)")})

if ($missing | length) > 0 {
    print "⚠️  These devices aren't attached right now:"
    $missing | each {|r| print $"     ($r.name)  ($r.vid):($r.pid)" }
    print ""
    print "  Indices only land as written when every device is present at boot."
    print "  If the USB switch is flipped away, flip it back and re-run."
    print "  If this isn't antimond, this helper isn't for this machine."
    exit 1
}

if (not ($dest | path exists)) or ((open $dest) != (open $src)) {
    sudo cp $src $dest
    print $"✅ Installed ($dest)"
} else {
    print $"✅ ($dest) already up to date"
}

print ""
print "Card indices after next boot:"
$expected | each {|r| print $"  ($r.index)  ($r.name)" }
print ""
print "Takes effect on reboot. Don't reload snd_usb_audio while audio is in use."
print "If duplicate PipeWire nodes ever pile up again:"
print "  systemctl --user restart wireplumber pipewire pipewire-pulse"
