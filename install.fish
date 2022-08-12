#!/usr/bin/fish

if string match -r WSL (uname -r) >/dev/null
  mkdir -p ~/.ssh 
  sudo apt install -y socat 
  wget https://github.com/BlackReloaded/wsl2-ssh-pageant/releases/download/v1.3.0/wsl2-ssh-pageant.exe -O ~/.ssh/wsl2-ssh-pageant.exe
  chmod +x ~/.ssh/wsl2-ssh-pageant.exe
end

source 'dotfiles/.config/fish/functions/update.fish'

update
