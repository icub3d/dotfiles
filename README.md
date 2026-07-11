# dotfiles

My dotfiles

# Arch Linux

For faster pacman downloads during the initial bootstrap, uncomment the
`ParallelDownloads` line in `/etc/pacman.conf` (with `=`):

```
sed -i 's/#ParallelDownloads = 5/ParallelDownloads = 5/g' /etc/pacman.conf
```

(`update-system` does this automatically afterwards.)

Do a basic install — make sure you include:

```
base base-devel linux linux-firmware nushell git iptables-nft sudo [amd-ucode|intel-ucode] pipewire neovim efivar efibootmgr networkmanager
```

# Dotfiles Installation

```bash
mkdir -p ~/dev
git clone https://github.com/icub3d/dotfiles ~/dev/dotfiles
cd ~/dev/dotfiles
nu install.nu
```

`install.nu` symlinks the nushell config and then calls `update-system`, which
installs `paru`, the packages listed in `.selected_packages`, and runs the
matching `packages/post-install/*.nu` scripts.

# Boot & Login Manager (systemd-boot & greetd)

We configure systemd-boot loader entries with specific PCIe performance profiles, standard system loglevels, and beautiful Catppuccin console (TTY) colors. In addition, we configure `greetd` with `tuigreet` as the login manager using a matching console theme that launches a `niri` session.

## Configuration Files

*   **systemd-boot entry:** `/boot/loader/entries/arch.conf` (sets kernel parameters and console palette)
*   **greetd greeter:** `/etc/greetd/config.toml` (uses `tuigreet` configured to launch `niri-session`)

## Helper Script

A dedicated helper script is provided at `helpers/boot-login.nu` to audit and apply these configurations safely.

### 🔍 Run status check / audit:

To check if your local configurations are active and in-sync with the repository:

```bash
nu helpers/boot-login.nu check

# Run with sudo to view full detailed kernel options and partition UUID audit:
sudo nu helpers/boot-login.nu check
```

### ⚙️ Apply configurations:

You can deploy the greetd configuration and the systemd-boot loader entry together or separately:

```bash
# Apply both configurations and check status (recommended)
sudo nu -c "use helpers/boot-login.nu; boot-login apply-all"

# Or apply them individually:
sudo nu -c "use helpers/boot-login.nu; boot-login apply-boot"
sudo nu -c "use helpers/boot-login.nu; boot-login apply-greetd"
```

> [!NOTE]
> `apply-boot` dynamically auto-detects the root partition's UUID using `findmnt`. You can optionally override this by passing the `--uuid` parameter:
> ```bash
> sudo nu -c "use helpers/boot-login.nu; boot-login apply-boot --uuid 'your-custom-uuid'"
> ```

## Setup Git


Add this to `~/.gitconfig.local`:

```conf
[user]
	name = Joshua Marsh (icub3d)
	email = joshua.marshian@gmail.com
	signingkey = [KEY]
```

If you want GitHub auth (gh is installed via the package manifests):

```bash
gh auth login
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

# Firefox / Bitwarden Lag (Multi-GPU)

If you experience "bursty" typing lag in Firefox or Bitwarden popups on a multi-GPU setup (e.g., AMD + NVIDIA), it is likely due to the compositor trying to sync frames across GPUs.

**The Fix:**
1. Prioritize the AMD card for wlroots-based compositors in `~/.config/environment.d/wayland.conf`:

```conf
WLR_DRM_DEVICES=/dev/dri/card1:/dev/dri/card0
```

*   `card1`: Primary AMD GPU (7900 XTX)
*   `card0`: Integrated AMD GPU
*   Excluded `card2`: NVIDIA GPU (reserved for AI/CUDA)

2. For Niri (which uses the Smithay backend and ignores `WLR_DRM_DEVICES`), ignore the Nvidia GPU in `~/.config/niri/config.kdl`:

```kdl
debug {
    ignore-drm-device "/dev/dri/renderD130" // Nvidia GPU
}
```


**GPU Helper Script:**
Use `nu helpers/gpu.nu` to check clocks and performance levels. If UI stuttering persists during video playback, you can force the AMD GPU into high-performance mode:

```bash
nu -c 'use helpers/gpu.nu; gpu set-perf high'
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
