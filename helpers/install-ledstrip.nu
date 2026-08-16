#!/usr/bin/env nu

# Run this as yourself, NOT with sudo. Under sudo the uv cache would be built for
# root rather than the account the unit runs as. The privileged steps prompt for
# a password on their own.
if (^id -u | str trim | into int) == 0 {
    error make { msg: "Run this without sudo -- it prompts for the steps that need it." }
}

# Build the script's dependency environment ahead of time, so that startup never
# spends time resolving. bleak comes from uv rather than a system pacman package.
uv sync --script ./ledstrip.py

# Retire the old user unit: it could not order itself against bluetooth.service,
# so at shutdown BlueZ was already gone and the strip stayed on.
let stale = ($env.HOME | path join ".config/systemd/user/ledstrip.service")
if ($stale | path exists) {
    systemctl --user disable --now ledstrip.service
    rm $stale
    systemctl --user daemon-reload
}

sudo cp ./ledstrip.service /etc/systemd/system/ledstrip.service
sudo systemctl daemon-reload
sudo systemctl enable --now ledstrip.service
