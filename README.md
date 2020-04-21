# dotfiles

My dotfiles

# Arch Linux Basic Install

```sh
# Verify UEFI
ls /sys/firmware/efi/efivars

timedatectl set-ntp true

fdisk -l
mkfs.ext4 /dev/sdX1
mount /dev/sdX1 /mnt

pacstrap /mnt base base-devel git sudo grub efibootmgr dhcpcd linux fish vim
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

ln -sf /usr/share/zoneinfo/America/Denver /etc/localtime
hwclock --systohc

sed -i -e 's/#en_US.UTF-8/en_US.UTF-8/g' /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" >/etc/locale.conf

echo "hostname" >/etc/hostname
echo "127.0.0.1 localhost" >>/etc/hosts
echo "127.0.1.1 hostname.localdomain hostname" >>/etc/hosts

passwd
useradd -m jmarsh
usermod -aG wheel jmarsh
chsh -s /usr/bin/fish jmarsh
passwd jmarsh

echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers.d/wheel
chmod 0440 /etc/sudoers.d/wheel

grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable dhcpcd@enp1s0

exit

reboot
```

# MSI Airplane Mode Button

add `acpi_osi=! acpi_osi='Windows 2009'` to `GRUB_CMDLINE_LINUX_DEFAULT` in `/etc/default/grub`.

# Grub Options

GRUB_DEFAULT=0
GRUB_TIMEOUT=5
GRUB_TERMINAL_INPUT=console
GRUB_GFXMODE=1920x1080x32
GRUB_GFXPAYLOAD_LINUX=keep
GRUB_BACKGROUND="/boot/grub/splash.png"
GRUB_FONT="/boot/grub/inconsolata.pf2"
GRUB_THEME="/boot/grub/marshians-theme/theme.txt"

# Mirror List

Set `/etc/pacman.d/mirrorlist` to:

```
Server = https://mirrors.xtom.com/archlinux/$repo/os/$arch
Server = https://mirrors.kernel.org/archlinux/$repo/os/$arch
Server = https://mirrors.sonic.net/archlinux/$repo/os/$arch
```

# Marshians Repo

Add to `/etc/pacman.conf`:

```
[marshians]
SigLevel = Optional TrustAll
Server = https://repos.themarshians.com/archlinux/marshians/
```
