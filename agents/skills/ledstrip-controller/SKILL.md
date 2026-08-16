---
name: ledstrip-controller
description: DayBetter BLE LED strip controller. Use when the user wants to turn the LED lights or strip on/off, or change their color, brightness, effect speed, preset, or make them flash — e.g. "turn the lights blue", "dim the lights", "flash the lights red and green".
---

# LED Strip Controller

## Overview
Drives the DayBetter LED strip (`P031_758B`, `80:AC:C8:68:75:8B`) over Bluetooth LE
via `helpers/ledstrip.py`, a `uv` PEP 723 script that resolves its own `bleak`
dependency.

`ledstrip.service` (user unit) runs `ledstrip.py daemon`, which holds the strip's
single BLE connection for the whole session, powers the strip on at login, and
powers it off on shutdown. Every other subcommand is a thin client that talks to
the daemon's socket at `$XDG_RUNTIME_DIR/ledstrip.sock` — so commands return in
well under a second. If no daemon is running the client falls back to connecting
directly, which costs ~7s per command.

## Commands

```
~/dev/dotfiles/helpers/ledstrip.py on
~/dev/dotfiles/helpers/ledstrip.py off
~/dev/dotfiles/helpers/ledstrip.py status
~/dev/dotfiles/helpers/ledstrip.py color <name|#rrggbb>
~/dev/dotfiles/helpers/ledstrip.py brightness <0-100>
~/dev/dotfiles/helpers/ledstrip.py speed <1-100>
~/dev/dotfiles/helpers/ledstrip.py preset <id> [--flag 0xff]
~/dev/dotfiles/helpers/ledstrip.py flash <color> <color> [...] [--interval 0.5]
~/dev/dotfiles/helpers/ledstrip.py stop
```

| Command | Range / values |
| :--- | :--- |
| `color` | `red` `orange` `yellow` `green` `cyan` `blue` `purple` `magenta` `pink` `white`, or any `#rrggbb` |
| `brightness` | 0–100 |
| `speed` | 1–100 (how fast the controller's own presets animate) |
| `preset` | known ids: `0x01` (static), `0x02`, `0x07`, `0x0b`, `0x1c`, and `0x0c` `0x20` `0xd3` `0xd5` (the IR remote's effect buttons, not yet individually identified) |
| `flash` | two or more colours, alternated by the daemon |

## Guidelines
- **`flash` is driven from this machine, not the controller.** The strip has no
  two-colour flash effect of its own, so the daemon pushes a new colour every
  interval. It therefore stops if the daemon stops. `preset` effects run on the
  controller itself and survive independently.
- `stop` ends a running `flash`; so does any other one-shot command, since an
  effect would otherwise immediately overwrite it.
- **The strip accepts only one BLE connection.** If the phone's DayBetter app is
  connected, the daemon cannot reach it and logs `not advertising` while retrying
  with backoff. That is the first thing to suspect on failure — tell the user to
  close the app or disable phone Bluetooth.
- Setting `color` or `brightness` implicitly moves the strip onto static preset
  `0x01`; this is the controller's behaviour, not a bug.
- Do not `systemctl start/stop ledstrip.service` just to toggle the lights — that
  starts and stops the daemon. Use `on`/`off`.
- Check the daemon with `systemctl --user status ledstrip` and
  `journalctl --user -u ledstrip -n 20`.

## Protocol reference (for extending the script)
Frames are `a0 <cmd> <len> <payload...> <crc16>`, where `len = len(payload) + 3` and
the checksum is **CRC-16/MODBUS** over all preceding bytes, little-endian. The
controller ignores everything until the two-frame `CCHIP` handshake completes.

| Cmd | Meaning | Payload |
| :--- | :--- | :--- |
| `0x10` | status request | `01` |
| `0x11` | power | `00` off / `01` on |
| `0x12` | preset | id, flag |
| `0x13` | brightness | `00`–`64` |
| `0x15` | color | R, G, B, `ff` |
| `0x16` | speed | `01`–`64` |

Notifications on `0000f031-…`: `a1 10 11 …` is a status report (payload byte 0
power, 1–2 preset, 3 brightness, 4 speed, 6–8 RGB); `a1 <cmd> 04 <ok>` is a
per-command ack where `ok` is `01` on success. **Preset changes are not pushed** —
`status` polls for them, which is how IR remote presses become observable.

New opcodes can be found by capturing the vendor app with Android's Bluetooth HCI
snoop log and filtering ATT writes in `tshark`.
