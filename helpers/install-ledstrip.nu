#!/usr/bin/env nu

# Run this as yourself, NOT with sudo. Under sudo the systemctl --user calls have
# no session bus to talk to, and enable-linger would name root instead of you.
# The one privileged step prompts for a password on its own.
if (^id -u | str trim | into int) == 0 {
    error make { msg: "Run this without sudo -- it prompts for the one step that needs it." }
}

# Lingering lets the user manager start at boot and stop at shutdown without an
# interactive login, which is what makes the daemon run at all outside a session.
sudo loginctl enable-linger $env.USER

# Build the script's dependency environment ahead of time, so that startup never
# spends time resolving. bleak comes from uv rather than a system pacman package.
uv sync --script ./ledstrip.py

let user_service_dir = ($env.HOME | path join ".config" "systemd" "user")
mkdir $user_service_dir

let src = ($env.HOME | path join "dev/dotfiles/dotfiles/.config/systemd/user/ledstrip.service")
let dst = ($user_service_dir | path join "ledstrip.service")
ln -sf $src $dst

systemctl --user daemon-reload
systemctl --user enable --now ledstrip.service
