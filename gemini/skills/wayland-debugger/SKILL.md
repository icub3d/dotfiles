---
name: wayland-debugger
description: Wayland and XDG Desktop Portal setup troubleshooter. Use to resolve screen-sharing, clipboard, or portal issues specific to the Niri/Ghostty stack.
---

# Wayland Debugger

## Overview
Fixes Wayland environment and portal issues, primarily focusing on `environment.d/wayland.conf` and Niri integrations.

## Guidelines
- When debugging screen-sharing or portal issues, verify the `XDG_CURRENT_DESKTOP` and related portal variables in `environment.d/wayland.conf`.
- Ensure clipboard utilities (like `wl-clipboard`) are correctly integrated.
- Check system logs for portal-related failures before applying configuration changes.