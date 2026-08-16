#!/usr/bin/env nu

# Lingering lets the user manager start at boot and stop at shutdown without an
# interactive login, which is what makes ExecStart/ExecStop fire at all.
sudo loginctl enable-linger $env.USER

# Build the script's dependency environment ahead of time, so that boot never
# spends time resolving. bleak comes from uv rather than a system pacman package.
uv sync --script ./ledstrip.py

let user_service_dir = ($env.HOME | path join ".config" "systemd" "user")
mkdir $user_service_dir

let src = ($env.HOME | path join "dev/dotfiles/dotfiles/.config/systemd/user/ledstrip.service")
let dst = ($user_service_dir | path join "ledstrip.service")
ln -sf $src $dst

systemctl --user daemon-reload
systemctl --user enable --now ledstrip.service
