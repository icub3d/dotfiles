---
name: liquidctl-automator
description: Hardware automation and cooling profile manager. Use when interacting with liquidctl, updating cooling profiles, or modifying systemd units for hardware control.
---

# Liquidctl Automator

## Overview
Manages `liquidctl` custom rules and services located in `helpers/` to control cooling profiles, lighting effects, and background systemd services.

## Guidelines
- When updating hardware parameters, check `helpers/liquidcfg.nu` and `helpers/99-liquidctl-custom.rules`.
- Ensure changes to the systemd unit `helpers/liquidcfg.service` maintain the correct dependencies and execution paths.
- Keep cooling profiles quiet during normal operations and aggressive during VM/gaming loads.