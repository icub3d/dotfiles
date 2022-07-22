#!/usr/bin/fish

#term info for 24 bit color in tmux and shell
tic -x -o $HOME/.terminfo xterm-24bit.terminfo

# max watchers
echo "fs.inotify.max_user_watches=524288" | sudo tee /etc/sysctl.d/99-inotify.conf >/dev/null
sudo sysctl --system

# setup samba information
if ! test -f ~/.smbclient.conf 
  read -l -P "username: " SAMBA_USERNAME
  read -l -P "password: " SAMBA_PASSWORD
  echo -e "username=$SAMBA_USERNAME\npassword=$SAMBA_PASSWORD\n" >~/.smbclient.conf
end

# update cli-tools
set ARCH (uname -m)
smbclient -A ~/.smbclient.conf --directory files -c "get cli-tools.$ARCH.zip /tmp/cli-tools.zip" //srv2/documents 
pushd $HOME/bin
unzip /tmp/cli-tools.zip
popd
rm /tmp/cli-tools.zip

# install spark
sh -c "curl https://raw.githubusercontent.com/holman/spark/master/spark -o ~/bin/spark && chmod +x ~/bin/spark"
