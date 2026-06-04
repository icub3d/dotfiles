---
name: systemd-manager
description: Manages systemd user and system unit files in the dotfiles repo — services, timers, socket activation, device dependencies, and install/reload workflows. Use when creating or editing .service, .timer, or .socket files in helpers/ or dotfiles/.config/systemd/.
---

# Systemd Manager

## Overview
This skill handles systemd unit authoring and maintenance across the dotfiles repo. It understands both system units (installed via root, e.g., `liquidcfg.service`) and user units (under `dotfiles/.config/systemd/user/`), and knows how to wire device dependencies, suspend/resume hooks, and graphical-session ordering.

## Key File Locations

| Path | Purpose |
| :--- | :--- |
| `helpers/liquidcfg.service` | System unit for liquidctl hardware init (device-dependent) |
| `helpers/liquidcfg-user.service` | User unit variant for the same (suspend-resume) |
| `dotfiles/.config/systemd/user/noctalia.service` | Quickshell Niri shell service (graphical-session) |
| `dotfiles/.config/systemd/user/gnome-extensions.service` | dconf-based oneshot for GNOME extension state |
| `~/.config/systemd/user/rclone-gdrive.service` | `Type=notify` FUSE mount for Google Drive (not yet in dotfiles) |

## Core Capabilities

### 1. Unit Authoring
Write correct `[Unit]`, `[Service]`, and `[Install]` sections for common patterns:
- `Type=oneshot` with `RemainAfterExit=true` for setup scripts.
- `Type=simple` / `Type=notify` for long-running daemons.
- `Restart=on-failure` with `RestartSec=` for resilient services.

### 2. Device Dependencies
For hardware-dependent units (liquidctl pattern):
- Use `Requires=` + `After=` for each `dev-*.device` udev path.
- Device unit names are derived from the `/dev/` path by replacing `/` with `-` and `.` with `\x2e`: e.g., `/dev/commander0` → `dev-commander0.device`.
- Add `After=suspend.target` and `WantedBy=suspend.target` to re-run on resume.

### 3. User vs. System Units
- **System units** (`/etc/systemd/system/`): installed by root, can own `/dev` devices directly.
- **User units** (`~/.config/systemd/user/`): run as the login user; cannot bind raw devices. Use `WantedBy=default.target` (auto-start at login) or `WantedBy=graphical-session.target` (Wayland/X11).
- For graphical services (Wayland compositors, shell components): use `BindsTo=graphical-session.target` + `After=graphical-session.target`.

### 4. Environment and Working Directory
- Pass environment with `Environment=KEY=VALUE` (inline) or `EnvironmentFile=` for secrets.
- Set `WorkingDirectory=` when the service executable expects a specific CWD.
- For Wayland services, include `Environment=QT_QPA_PLATFORM=wayland` or `WAYLAND_DISPLAY=` as needed (see noctalia.service).

### 5. Install and Reload Workflow
After editing a unit file tracked in dotfiles:
1. Verify the symlink is in place (see `install.nu` — `dotfiles-guardian` skill).
2. Run `systemctl daemon-reload` (system) or `systemctl --user daemon-reload` (user).
3. Enable with `systemctl enable --now <unit>` or restart with `systemctl restart <unit>`.
4. Check status: `systemctl status <unit>` / `journalctl -u <unit> -n 50`.

## Guidelines
- Prefer `Requires=` over `Wants=` for hard device dependencies — a missing device should prevent the service from starting rather than silently succeeding.
- Never use `ExecStartPre=sleep` as a timing hack; use proper `After=` ordering or `Condition*=` directives.
- For oneshot units that configure hardware, list each `ExecStart=` as a separate line (as in liquidcfg.service) rather than chaining with `&&` — this makes failures easier to attribute.
- Use `StandardOutput=journal` / `StandardError=journal` (the defaults) — do not redirect to files unless the service itself requires it.

## Examples
- "Add a systemd user timer to run my backup script every night at 2am."
- "Create a system service for a new udev device that runs after suspend resumes."
- "Wire noctalia.service to restart if it crashes, but with a 5-second backoff."
- "Add a graphical-session user service for a new Wayland status bar daemon."
