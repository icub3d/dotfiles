#!/usr/bin/env nu

# Ensure udev rules are installed for device access
sudo cp ./99-liquidctl-custom.rules /etc/udev/rules.d/
sudo udevadm control --reload-rules
sudo udevadm trigger

# Enable lingering for the current user to allow user services to start at boot
sudo loginctl enable-linger $env.USER

# Install and enable the user-level systemd service
let user_service_dir = ($env.HOME | path join ".config" "systemd" "user")
mkdir $user_service_dir
cp liquidcfg-user.service ($user_service_dir | path join "liquidcfg.service")

systemctl --user daemon-reload
systemctl --user enable --now liquidcfg.service

# Disable the old system-level service if it exists
if (systemctl is-enabled liquidcfg.service | str contains "enabled") {
    sudo systemctl disable --now liquidcfg.service
}
