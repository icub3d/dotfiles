#!/usr/bin/fish

#term info for 24 bit color in tmux and shell
tic -x -o $HOME/.terminfo xterm-24bit.terminfo

# max watchers
echo "fs.inotify.max_user_watches=524288" | sudo tee /etc/sysctl.d/99-inotify.conf >/dev/null
sudo sysctl --system

# update cli-tools
update-cli-tools
