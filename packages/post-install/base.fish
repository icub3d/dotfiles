#!/usr/bin/fish

# max watchers
echo "fs.inotify.max_user_watches=524288" | sudo tee /etc/sysctl.d/99-inotify.conf >/dev/null
sudo sysctl --system

# update cli-tools
get-cli-tools
