# dotfiles

My dotfiles

# Arch Linux

Do a basic install make sure you include:

``` 
fish git iptables-nft base-devel sudo amd-ucode pipewire lsb-release
```

# Ubuntu / WSL Install

```bash
sudo apt install -y fish curl git ca-certificates curl gnupg lsb-release
./helpers/go.fish
./helpers/ppa.sh
sudo chsh -s /usr/bin/fish jmarsh
fish install.fish
```

## GUI Stuff
```bash
sudo apt install kitty 
./helpers/chrome.fish
./helpers/fonts.fish
```

## Yubikey

https://www.thetestspecimen.com/posts/wsl2-yubikey/

```powershell
mkdir C:\Users\joshu\AppData\Roaming\gnupg

echo "enable-putty-support
enable-ssh-support
default-cache-ttl 600
max-cache-ttl 7200
" > C:\Users\Dave\AppData\Roaming\gnupg\gpg-agent.conf

gpg --recv-keys 3A9A1EDB4D5AD7A570BADC538A18F7931D00BF38
gpg --edit-key 3A9A1EDB4D5AD7A570BADC538A18F7931D00BF38
> trust
> quit

gpg --list-keys
gpgconf --kill gpg-agent
gpg-connect-agent /bye
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

# Firefox Theme

https://color.firefox.com/?theme=XQAAAAINAQAAAAAAAABBKYhm849SCia2CaaEGccwS-xMDPr6vjCkinuVw7Rh0WX8gM_c2TvB3-esAFTiupayP4GQLS2fI8oYy0uawh_8cVtu99eOYhDmnCmqQ8gsax812SPJeRBaP8FQlXs_t5GJqRtQcDC0dvNpFyxMhn5I7pdRo_WGVHACD5lUOjsRZECYOmTUC3L6m4McnTwSV2UXD0rdARNAQCEOTLz_kod6JZdDs1H0wDNLORmuPzQn-__Dpm7g

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
