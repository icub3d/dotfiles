#!/usr/bin/env python3
"""
footswitch - Program the iKKEGOL USB foot pedal (VID=0x0c45, PID=0x7403)

Protocol reverse-engineered from FootSwitch-7.4.4.exe (IL disassembly):

  Read key N:    write [0x00, 0x01, 0x82, 0x08, N, 0,0,0,0]
                 read  11 bytes → [_, status, type, modifier, keycode, ...]

  Write key N:   write [0x00, 0x01, 0x81, 0x08, N, 0,0,0,0]  (address)
                 write [0x00, 0x08, type, modifier, keycode, 0,0,0,0]  (data)

  Flash to ROM:  write [0x00, 0x01, 0x80, 0x80, 0x01, 0,0,0,0]

  Type byte: 0x81 = keyboard (normal press), 0x01 = keyboard (long press),
             0x07 = consumer/media, 0x00 = disabled

Usage:
  sudo footswitch.py read
  sudo footswitch.py write 1 ctrl+z
  sudo footswitch.py write 2 XF86AudioPlay
  sudo footswitch.py write 3 f5
  sudo footswitch.py keys
"""

import sys
import time
import argparse

try:
    import hid
except ImportError:
    print("Error: 'hid' package not found. Install with: pip install hid", file=sys.stderr)
    print("Or via pacman: paru -S python-hid", file=sys.stderr)
    sys.exit(1)

VID = 0x3553
PID = 0xB001
WRITE_SIZE = 9
READ_SIZE = 11

# USB HID Keyboard Page (0x07) usage codes
KEYBOARD_KEYS: dict[str, int] = {
    "a": 0x04, "b": 0x05, "c": 0x06, "d": 0x07, "e": 0x08,
    "f": 0x09, "g": 0x0A, "h": 0x0B, "i": 0x0C, "j": 0x0D,
    "k": 0x0E, "l": 0x0F, "m": 0x10, "n": 0x11, "o": 0x12,
    "p": 0x13, "q": 0x14, "r": 0x15, "s": 0x16, "t": 0x17,
    "u": 0x18, "v": 0x19, "w": 0x1A, "x": 0x1B, "y": 0x1C,
    "z": 0x1D,
    "1": 0x1E, "2": 0x1F, "3": 0x20, "4": 0x21, "5": 0x22,
    "6": 0x23, "7": 0x24, "8": 0x25, "9": 0x26, "0": 0x27,
    "enter": 0x28, "return": 0x28,
    "esc": 0x29, "escape": 0x29,
    "backspace": 0x2A,
    "tab": 0x2B,
    "space": 0x2C,
    "minus": 0x2D, "-": 0x2D,
    "equal": 0x2E, "=": 0x2E,
    "leftbrace": 0x2F, "[": 0x2F,
    "rightbrace": 0x30, "]": 0x30,
    "backslash": 0x31, "\\": 0x31,
    "semicolon": 0x33, ";": 0x33,
    "apostrophe": 0x34, "'": 0x34,
    "grave": 0x35, "`": 0x35,
    "comma": 0x36, ",": 0x36,
    "dot": 0x37, "period": 0x37, ".": 0x37,
    "slash": 0x38, "/": 0x38,
    "capslock": 0x39,
    "f1": 0x3A, "f2": 0x3B, "f3": 0x3C, "f4": 0x3D,
    "f5": 0x3E, "f6": 0x3F, "f7": 0x40, "f8": 0x41,
    "f9": 0x42, "f10": 0x43, "f11": 0x44, "f12": 0x45,
    "print": 0x46, "scrolllock": 0x47, "pause": 0x48,
    "insert": 0x49, "home": 0x4A, "pageup": 0x4B,
    "delete": 0x4C, "del": 0x4C,
    "end": 0x4D, "pagedown": 0x4E,
    "right": 0x4F, "left": 0x50, "down": 0x51, "up": 0x52,
    "numlock": 0x53,
    "kp/": 0x54, "kp*": 0x55, "kp-": 0x56, "kp+": 0x57,
    "kpenter": 0x58,
    "kp1": 0x59, "kp2": 0x5A, "kp3": 0x5B, "kp4": 0x5C,
    "kp5": 0x5D, "kp6": 0x5E, "kp7": 0x5F, "kp8": 0x60,
    "kp9": 0x61, "kp0": 0x62, "kpdot": 0x63,
    "f13": 0x68, "f14": 0x69, "f15": 0x6A, "f16": 0x6B,
    "f17": 0x6C, "f18": 0x6D, "f19": 0x6E, "f20": 0x6F,
    "f21": 0x70, "f22": 0x71, "f23": 0x72, "f24": 0x73,
    "menu": 0x76,
}

# Modifier bit masks
MODIFIERS: dict[str, int] = {
    "ctrl": 0x01, "lctrl": 0x01,
    "shift": 0x02, "lshift": 0x02,
    "alt": 0x04, "lalt": 0x04,
    "super": 0x08, "lsuper": 0x08, "win": 0x08, "meta": 0x08,
    "rctrl": 0x10,
    "rshift": 0x20,
    "ralt": 0x40, "altgr": 0x40,
    "rsuper": 0x80, "rwin": 0x80,
}

# HID Consumer Usage Page (0x0C) codes, matching X11 XF86 key names
CONSUMER_KEYS: dict[str, int] = {
    "xf86audioplay": 0xCD,
    "xf86audiopause": 0xCD,
    "xf86audioplaypause": 0xCD,
    "xf86audiostop": 0xB7,
    "xf86audioprev": 0xB6,
    "xf86audioprevious": 0xB6,
    "xf86audionext": 0xB5,
    "xf86audioforward": 0xB3,
    "xf86audiorewind": 0xB4,
    "xf86audiomute": 0xE2,
    "xf86audioraisevolume": 0xE9,
    "xf86audiolowervolume": 0xEA,
    "xf86audiomicmute": 0xF8,
    "xf86eject": 0xB8,
    "xf86brightnessup": 0x6F,
    "xf86brightnessdown": 0x70,
    "xf86sleep": 0x32,
    "xf86wakeup": 0x33,
    "xf86calculator": 0x192,
    "xf86www": 0x196,
    "xf86mail": 0x18A,
    "xf86search": 0x221,
    "xf86back": 0x224,
    "xf86forward": 0x225,
    "xf86stop": 0x226,
    "xf86refresh": 0x227,
}

TYPE_KEYBOARD = 0x01
TYPE_CONSUMER = 0x07
TYPE_DISABLED = 0x00

# Build reverse map preferring longer/more-descriptive names (e.g. "enter" over "\r")
KEYBOARD_NAMES: dict[int, str] = {}
for _k, _v in KEYBOARD_KEYS.items():
    if _v not in KEYBOARD_NAMES or len(_k) > len(KEYBOARD_NAMES[_v]):
        KEYBOARD_NAMES[_v] = _k
CONSUMER_NAMES = {v: k for k, v in CONSUMER_KEYS.items()}
MODIFIER_BITS = [
    (0x01, "ctrl"), (0x02, "shift"), (0x04, "alt"), (0x08, "super"),
    (0x10, "rctrl"), (0x20, "rshift"), (0x40, "ralt"), (0x80, "rsuper"),
]

PEDAL_LABELS = {1: "left", 2: "middle", 3: "right"}


def open_device() -> hid.device:
    devices = hid.enumerate(VID, PID)
    if not devices:
        sys.exit(f"Error: Device {VID:04x}:{PID:04x} not found. Is the pedal plugged in?")

    # Interface 1 (usage=0, undefined) is the raw programming channel.
    # Interface 0 is the keyboard/mouse/consumer composite interface.
    prog = [d for d in devices if d["interface_number"] == 1]
    target = prog[0] if prog else max(devices, key=lambda d: d["interface_number"])

    dev = hid.device()
    try:
        dev.open_path(target["path"])
    except OSError as e:
        sys.exit(f"Error opening device: {e}\nTry running with sudo, or install the udev rule.")
    dev.set_nonblocking(False)
    return dev


def send(dev: hid.device, data: list[int]) -> None:
    assert len(data) == WRITE_SIZE, f"Packet must be {WRITE_SIZE} bytes, got {len(data)}"
    dev.write(data)
    time.sleep(0.025)


def read_raw(dev: hid.device, pedal: int) -> list[int]:
    send(dev, [0x00, 0x01, 0x82, 0x08, pedal, 0, 0, 0, 0])
    return list(dev.read(READ_SIZE, timeout_ms=500))


def decode_response(data: list[int]) -> str:
    # Response layout: [0x08, type, modifier, keycode, ...]
    if not data or len(data) < 4:
        return "no response"
    if data[0] == 0xFF:
        return "error (device fault)"

    key_type = data[1]

    if key_type == TYPE_DISABLED:
        return "disabled"

    if key_type == TYPE_KEYBOARD:
        modifier = data[2]
        keycode  = data[3]
        parts = [name for bit, name in MODIFIER_BITS if modifier & bit]
        parts.append(KEYBOARD_NAMES.get(keycode, f"key:0x{keycode:02x}"))
        return "+".join(parts)

    if key_type == TYPE_CONSUMER:
        # Consumer code is at byte[2] (modifier slot is unused for consumer)
        code = data[2]
        return CONSUMER_NAMES.get(code, f"consumer:0x{code:02x}")

    return f"unknown (type=0x{key_type:02x} mod=0x{modifier:02x} key=0x{keycode:02x})"


def parse_key(key_str: str) -> tuple[int, int, int]:
    """Return (type_byte, modifier_byte, keycode_byte) for a key string."""
    parts = [p.strip().lower() for p in key_str.split("+")]

    # Consumer/media key — no modifiers
    if len(parts) == 1 and parts[0] in CONSUMER_KEYS:
        code = CONSUMER_KEYS[parts[0]]
        if code > 0xFF:
            sys.exit(f"Error: Consumer key 0x{code:04x} exceeds single byte — not supported by this device.")
        return (TYPE_CONSUMER, 0x00, code)



    modifier = 0x00
    keycode: int | None = None

    for part in parts:
        if part in MODIFIERS:
            modifier |= MODIFIERS[part]
        elif part in KEYBOARD_KEYS:
            if keycode is not None:
                sys.exit(f"Error: Multiple non-modifier keys in '{key_str}' — only one allowed.")
            keycode = KEYBOARD_KEYS[part]
        else:
            sys.exit(
                f"Error: Unknown key '{part}'.\n"
                f"Run 'footswitch.py keys' to see all available keys."
            )

    if keycode is None:
        sys.exit(f"Error: No non-modifier key in '{key_str}'.")

    return (TYPE_KEYBOARD, modifier, keycode)


def cmd_read(dev: hid.device) -> None:
    print(f"{'Pedal':<10} {'Assignment':<30} {'Raw bytes'}")
    print(f"{'─' * 10} {'─' * 30} {'─' * 33}")
    for pedal in range(1, 4):
        raw = read_raw(dev, pedal)
        label = PEDAL_LABELS[pedal]
        assignment = decode_response(raw)
        raw_str = " ".join(f"{b:02x}" for b in raw)
        print(f"{pedal} ({label:<6}) {assignment:<30} {raw_str}")


def cmd_write(dev: hid.device, pedal: int, key_str: str) -> None:
    key_type, modifier, keycode = parse_key(key_str)

    send(dev, [0x00, 0x01, 0x81, 0x08, pedal, 0, 0, 0, 0])
    if key_type == TYPE_CONSUMER:
        # Consumer code goes at byte[3]; byte[4] unused
        send(dev, [0x00, 0x08, key_type, keycode, 0, 0, 0, 0, 0])
    else:
        send(dev, [0x00, 0x08, key_type, modifier, keycode, 0, 0, 0, 0])
    send(dev, [0x00, 0x01, 0x80, 0x80, 0x01, 0, 0, 0, 0])

    label = PEDAL_LABELS[pedal]
    print(f"Pedal {pedal} ({label}): set to '{key_str}'")
    print(f"  type=0x{key_type:02x}  modifier=0x{modifier:02x}  keycode=0x{keycode:02x}")


def cmd_keys() -> None:
    print("Keyboard keys (combine with modifiers using +):")
    print("  Letters:    a-z")
    print("  Numbers:    0-9")
    print("  Function:   f1-f24")
    print("  Navigation: up down left right home end pageup pagedown insert delete")
    print("  Special:    enter esc backspace tab space capslock numlock scrolllock")
    print("              pause print menu")
    print("  Numpad:     kp0-kp9 kpenter kp+ kp- kp* kp/ kpdot")
    print("  Symbols:    - = [ ] \\ ; ' ` , . /")
    print()
    print("Modifier keys (prefix before + and key):")
    print("  ctrl shift alt super  (or lctrl lshift lalt lsuper)")
    print("  rctrl rshift ralt rsuper")
    print()
    print("Media / XF86 keys (used alone, no modifiers):")
    for name in sorted(CONSUMER_KEYS):
        print(f"  {name}")
    print()
    print("Examples:")
    print("  ctrl+z          ctrl+shift+s      alt+f4")
    print("  f5              XF86AudioPlay     XF86AudioMute")
    print("  XF86AudioNext   XF86AudioPrev     XF86AudioRaiseVolume")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Program the iKKEGOL USB foot pedal (0x0c45:0x7403)",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    sub = parser.add_subparsers(dest="command", required=True)

    sub.add_parser("read", help="Read current key assignments from all three pedals")

    write_p = sub.add_parser("write", help="Write a key assignment to a pedal")
    write_p.add_argument(
        "pedal", type=int, choices=[1, 2, 3],
        help="Pedal number: 1=left, 2=middle, 3=right",
    )
    write_p.add_argument(
        "key",
        help="Key to assign, e.g. ctrl+z, f5, XF86AudioPlay",
    )

    sub.add_parser("keys", help="List all supported key names")

    args = parser.parse_args()

    if args.command == "keys":
        cmd_keys()
        return

    dev = open_device()
    try:
        if args.command == "read":
            cmd_read(dev)
        elif args.command == "write":
            cmd_write(dev, args.pedal, args.key)
    finally:
        dev.close()


if __name__ == "__main__":
    main()
