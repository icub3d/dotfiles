# dotfiles

My dotfiles

# Arch Linux

You may want to use parallel downloads:

```
sed -i 's/#ParallelDownloads 5/ParallelDownloads 5/g' /etc/pacman.conf
```

Do a basic install make sure you include:

``` 
base base-devel linux linux-firmware nushell git iptables-nft sudo [amd-ucode|intel-ucode] pipewire neovim efivar efibootmgr networkmanager 
```

# Dotfiles Installation

```bash
mkdir -p ~/dev
git clone https://github.com/icub3d/dotfiles ~/dev/dotfiles
pushd ~/dev/dotfiles
nu install.nu
```

## Setup Git

Add this to ~/.gitconfig.local

```conf
[user]
	name = Joshua Marsh (icub3d)
	email = joshua.marshian@gmail.com
	signingkey = [KEY]
```

If you are using `gh` then:

```bash
gh auth setup-git
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

```sh
nu mirrors
```

# Docker Slow Stopping

```sudo systemctl edit docker``` and add:

```sh
[Unit]
After=containerd.service
Wants=containerd.service
```

# Firefox Theme

https://color.firefox.com/?theme=XQAAAAINAQAAAAAAAABBKYhm849SCia2CaaEGccwS-xMDPr6vjCkinuVw7Rh0WX8gM_c2TvB3-esAFTiupayP4GQLS2fI8oYy0uawh_8cVtu99eOYhDmnCmqQ8gsax812SPJeRBaP8FQlXs_t5GJqRtQcDC0dvNpFyxMhn5I7pdRo_WGVHACD5lUOjsRZECYOmTUC3L6m4McnTwSV2UXD0rdARNAQCEOTLz_kod6JZdDs1H0wDNLORmuPzQn-__Dpm7g


# GUI Links

- [Niri](https://yalter.github.io/niri/)
- [Niri Screencasting](https://github.com/YaLTeR/niri/wiki/Screencasting)
- [Noctalia Shell](https://github.com/noctalia-dev/noctalia-shell)
