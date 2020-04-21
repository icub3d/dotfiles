#!/usr/bin/fish

add_service gdm

get-marshian-images

gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
gsettings set org.gnome.Terminal.Legacy.Settings default-show-menubar false
gsettings set org.gnome.desktop.interface clock-format '24h'
gsettings set org.gnome.desktop.interface clock-show-date true
gsettings set org.gnome.desktop.interface clock-show-seconds true
gsettings set org.gnome.desktop.background show-desktop-icons 'false'
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.desktop.background picture-uri 'file:///home/jmarsh/Pictures/marshians-text-background-4k.png'
gsettings set org.gnome.desktop.screensaver picture-uri 'file:///home/jmarsh/Pictures/marshians-text-background-4k.png'

# TODO these aren't the same in arch linux.
# gsettings set org.gnome.settings-daemon.plugins.power lid-close-suspend-with-external-monitor 'false'
# gsettings set org.gnome.settings-daemon.plugins.power lid-close-battery-action 'suspend'

dconf write /org/gnome/shell/enabled-extensions "['desktop-icons@csoriano']"
dconf write /org/gnome/shell/extensions/desktop-icons/show-home false
dconf write /org/gnome/shell/extensions/desktop-icons/show-trash false

dconf write /org/gnome/shell/favorite-apps "['FirefoxDeveloperEdition.desktop', 'com.alacritty.Alacritty.desktop', 'org.gnome.Nautilus.desktop', 'code.desktop', 'virt-manager.desktop']"


# # TODO arch linux arc-gtk-theme
# 	install_aur tela-icon-theme-git bibata-cursor-theme
# 	gsettings set org.gnome.desktop.interface gtk-theme 'Arc'
# 	gsettings set org.gnome.desktop.interface icon-theme 'Tela'
# 	gsettings set org.gnome.desktop.interface cursor-theme 'Bibata_Ice'
# 	gsettings set org.gnome.desktop.sound theme-name 'Yaru'