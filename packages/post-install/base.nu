tic -x -o ($nu.home-path | path join ".terminfo") xterm-24bit.terminfo

echo "fs.inotify.max_user_watches=524288" | sudo tee /etc/sysctl.d/99-inotify.conf out> /dev/null
sudo sysctl --system
