#!/usr/bin/env nu
# Install udev rule and hwdb keyremap for the iKKEGOL foot pedal.

let dotfiles = ($nu.home-dir | path join "dev/dotfiles/helpers")

sudo cp $"($dotfiles)/99-footswitch.rules" /etc/udev/rules.d/99-footswitch.rules
sudo cp $"($dotfiles)/70-footswitch-keyremap.hwdb" /etc/udev/hwdb.d/70-footswitch-keyremap.hwdb
sudo systemd-hwdb update
sudo udevadm control --reload
sudo udevadm trigger --subsystem-match=usb --action=add

print "✅ udev rule and hwdb keyremap installed."
print "Unplug and replug the pedal (or reboot) to apply the hwdb remap."
