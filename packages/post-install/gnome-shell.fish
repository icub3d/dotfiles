#!/usr/bin/fish

add_service gdm

get-marshian-images

gsettings set org.gnome.desktop.peripherals.touchpad tap-to-click true
gsettings set org.gnome.desktop.interface clock-format '24h'
gsettings set org.gnome.desktop.interface clock-show-date true
gsettings set org.gnome.desktop.interface clock-show-seconds true
gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
gsettings set org.gnome.desktop.background show-desktop-icons 'false'
gsettings set org.gnome.desktop.session idle-delay 0
gsettings set org.gnome.desktop.background picture-uri 'file:///home/jmarsh/Pictures/marshians-green-background-4k.png'
gsettings set org.gnome.desktop.screensaver picture-uri 'file:///home/jmarsh/Pictures/marshians-green-background-4k.png'
gsettings set org.gnome.settings-daemon.plugins.power sleep-inactive-ac-type 'nothing'
gsettings set org.gnome.settings-daemon.plugins.power power-button-action  'suspend'

# TODO these aren't the same in arch linux.
# gsettings set org.gnome.settings-daemon.plugins.power lid-close-suspend-with-external-monitor 'false'
# gsettings set org.gnome.settings-daemon.plugins.power lid-close-battery-action 'suspend'

dconf write /org/gnome/shell/enabled-extensions "['desktop-icons@csoriano', 'trayIconsReloaded@selfmade.pl', 'user-theme@gnome-shell-extensions.gcampax.github.com']"
dconf write /org/gnome/shell/extensions/desktop-icons/show-home false
dconf write /org/gnome/shell/extensions/desktop-icons/show-trash false
dconf write /org/gnome/shell/favorite-apps "['firefoxdeveloperedition.desktop', 'org.wezfurlong.wezterm.desktop', 'discord.desktop', 'com.obsproject.Studio.desktop', 'org.gnome.Nautilus.desktop', 'virt-manager.desktop', 'net.lutris.Lutris.desktop', 'steam-native.desktop', 'minecraft-launcher.desktop']"
# dconf write /org/gnome/shell/extensions/user-theme/name 'marshians'
dconf write /org/gnome/mutter/keybindings/switch-monitor '@as []'

# stylus
dconf write '/org/gnome/desktop/peripherals/tablets/256c:006d/output' "['GSM', 'LG ULTRAGEAR', '107NTMX8J515']"
dconf write '/org/gnome/desktop/peripherals/tablets/256c:006d/left-handed' true
# dconf write '/org/gnome/desktop/peripherals/tablets/256c:006d/buttonA/action' "'keybinding'"
# dconf write '/org/gnome/desktop/peripherals/tablets/256c:006d/buttonA/keybinding' "'<Primary>z'"
# dconf write '/org/gnome/desktop/peripherals/tablets/256c:006d/buttonD/action' "'keybinding'"
# dconf write '/org/gnome/desktop/peripherals/tablets/256c:006d/buttonD/keybinding' "'<Primary><Shift>plus'"
# dconf write '/org/gnome/desktop/peripherals/tablets/256c:006d/buttonE/action' "'keybinding'"
# dconf write '/org/gnome/desktop/peripherals/tablets/256c:006d/buttonE/keybinding' "'<Primary>minus'"

# default browser
xdg-settings set default-web-browser firefoxdeveloperedition.desktop

