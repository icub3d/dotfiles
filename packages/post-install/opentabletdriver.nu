let blacklist = "/etc/modprobe.d/blacklist.conf"
let existing = if ($blacklist | path exists) { open $blacklist } else { "" }

if not ($existing | str contains 'blacklist hid_uclogic') {
    'blacklist hid_uclogic' | sudo tee -a $blacklist out> /dev/null
}
if not ($existing | str contains 'blacklist wacom') {
    'blacklist wacom' | sudo tee -a $blacklist out> /dev/null
}

# Modules may already be unloaded; ignore failure.
try { sudo rmmod hid_uclogic }
try { sudo rmmod wacom }

add-user-service opentabletdriver
