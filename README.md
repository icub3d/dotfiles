# dotfiles

My dotfiles

# WSL install

	sudo apt update && sudo apt uprade
	sudo apt install fish
	fish fish.fish
	chsh -s /usr/bin/fish
	fish dotfiles.fish
	fish go.fish
	./install.fish
	fish emacs.fish

# Arch Linux Basic Install

This should setup my common default values. I don't setup the disks
because they are different for each machine I have.

```bash
wget https://raw.githubusercontent.com/icub3d/dotfiles/main/archinstall-configs/config.json >config.json
wget https://github.com/icub3d/dotfiles/blob/main/archinstall-configs/creds.json >creds.json
archinstall --creds creds.json --config config.json

# enter into chroot when asked
passwd jmarsh
pacman -S amd_ucode # if AMD
pacman -S intel_ucode # if AMD
```

# Dotfiles Installation

```bash
mkdir -p ~/dev
git clone https://github.com/icub3d/dotfiles ~/dev/dotfiles
pushd ~/dev/dotfiles
fish dotfiles.fish
fish install.fish
```

# Syncthing

* Enable syncthing

```bash
systemctl enable --now --user syncthing
```

* http://localhost:8384 > Actions > Show ID

* http://otherhost:8384 > Add Remote Device

* Back on http://localhost:8384 you'll eventually see a request that
  you can approve and then after a few seconds you'll also see the new
  shares that you can map.

# 3rd Monitor Not Working

I kept cycling the power (unplug from monitor) until it finally was
recognized?!?!?


# Mirror List

Set `/etc/pacman.d/mirrorlist` to:

```
Server = https://mirrors.xtom.com/archlinux/$repo/os/$arch
Server = https://mirrors.kernel.org/archlinux/$repo/os/$arch
Server = https://mirrors.sonic.net/archlinux/$repo/os/$arch
```

# Docker Slow Stopping

```sudo systemctl edit docker``` and add:

```
[Unit]
After=containerd.service
Wants=containerd.service
```

# Tray Icons

https://extensions.gnome.org/extension/2890/tray-icons-reloaded/

# Firefox + Yubikey

Firefox kept asking for my password for the smart card part of the
yubikey. To fix this, I edited ```/etc/opensc.conf```. First, get the
name of the yubikey:

```sh
λ opensc-tool -l
# Detected readers (pcsc)
Nr.  Card  Features  Name
0    Yes             Yubico YubiKey OTP+FIDO+CCID (0011009304) 00 00
```

Next, add the *entire* name to the ```ignored_readers``` list:

```conf
app onepin-opensc-pkcs11 {
    ignored_readers = "Yubico YubiKey OTP+FIDO+CCID (0011009304) 00 00";
}

app opensc-pkcs11 {
    ignored_readers = "Yubico YubiKey OTP+FIDO+CCID (0011009304) 00 00";
}
```
