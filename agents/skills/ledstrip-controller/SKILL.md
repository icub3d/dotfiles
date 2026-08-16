---
name: ledstrip-controller
description: DayBetter BLE LED strip controller. Use when the user wants to turn the LED lights or strip on/off, or change their color, brightness, effect speed, or preset — e.g. "turn the lights blue", "dim the lights", "make the lights slower".
---

# LED Strip Controller

## Overview
Drives the DayBetter LED strip (`P031_758B`, `80:AC:C8:68:75:8B`) over Bluetooth LE
via `helpers/ledstrip.py`. The script is a `uv` PEP 723 script — run it directly,
it resolves its own `bleak` dependency and needs no venv activation.

## Commands

```
~/dev/dotfiles/helpers/ledstrip.py on
~/dev/dotfiles/helpers/ledstrip.py off
~/dev/dotfiles/helpers/ledstrip.py status
~/dev/dotfiles/helpers/ledstrip.py color <name|#rrggbb>
~/dev/dotfiles/helpers/ledstrip.py brightness <0-100>
~/dev/dotfiles/helpers/ledstrip.py speed <1-100>
~/dev/dotfiles/helpers/ledstrip.py preset <id> [--flag 0xff]
```

| Command | Range / values |
| :--- | :--- |
| `color` | `red` `orange` `yellow` `green` `cyan` `blue` `purple` `magenta` `pink` `white`, or any `#rrggbb` |
| `brightness` | 0–100 |
| `speed` | 1–100 (how fast presets animate) |
| `preset` | id seen in captures: `0x01`, `0x02`, `0x07`, `0x0b`, `0x1c`, `0xa1` |

`status` prints `power`, `brightness`, `speed`, `color`, and `preset`.

## Guidelines
- **Each invocation is a full connect cycle (~7s).** When the user asks for several
  changes at once, still issue separate calls, but tell them it will take a few
  seconds each rather than appearing to hang.
- **The strip accepts only one BLE connection.** If the phone's DayBetter app is
  connected, every command fails with `not advertising`. That is the first thing to
  suspect on failure — tell the user to close the app or disable phone Bluetooth.
- Setting `color` or `brightness` implicitly moves the strip off an animated preset
  onto the static preset `0x01`; this is the controller's behaviour, not a bug.
- Turning the lights on/off is also wired to `ledstrip.service` (user unit), which
  runs `on` at login and `off` at shutdown. Prefer the script for ad-hoc changes;
  do not `systemctl start/stop` the unit just to toggle the lights, as that also
  changes whether they come back on at next boot.
- Flash / Strobe / Fade / Smooth exist only on the IR remote, not over Bluetooth.
  The nearest Bluetooth equivalents are the presets plus `speed`.

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
per-command ack where `ok` is `01` on success.

New opcodes can be found by capturing the vendor app with Android's Bluetooth HCI
snoop log and filtering ATT writes in `tshark`.
