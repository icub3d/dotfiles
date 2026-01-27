do -i {
  tic -x -o ($nu.home-dir | path join ".terminfo") xterm-24bit.terminfo

  echo "kernel.perf_event_paranoid=-1" | sudo tee /etc/sysctl.d/100-perf.conf out> /dev/null
  echo "fs.inotify.max_user_watches=524288" | sudo tee /etc/sysctl.d/99-inotify.conf out> /dev/null
  sudo sysctl --system
}
