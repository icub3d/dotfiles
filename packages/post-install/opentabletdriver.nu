do -i {
  let blacklist = "/etc/modprobe.d/blacklist.conf"
  if (not ($blacklist | path exists)) or (not (open $blacklist | str contains 'blacklist hid_uclogic')) {
    echo 'blacklist hid_uclogic' | sudo tee -a $blacklist out> /dev/null
  }

  if (not ($blacklist | path exists)) or (not (open $blacklist | str contains 'blacklist wacom')) {
    echo 'blacklist wacom' | sudo tee -a $blacklist out> /dev/null
  }

  sudo rmmod hid_uclogic err> /dev/null
  sudo rmmod wacom err> /dev/null

  systemctl --user enable --now opentabletdriver
}
