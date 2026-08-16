#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = ["bleak>=3.0,<4"]
# ///
"""Control the DayBetter LED strip (P031_758B) over Bluetooth LE.

Protocol recovered from Android HCI snoop captures of the vendor app. Frames are

    a0 <cmd> <len> <payload...> <crc16>

where len is len(payload) + 3, and the checksum is CRC-16/MODBUS over everything
preceding it, emitted little-endian. The controller silently ignores every
command until the two-frame "CCHIP" handshake completes -- which is why the
vendor app takes ~20s to become responsive after connecting.

The strip accepts a single BLE connection at a time, so it is unreachable while
a phone has the vendor app connected.
"""

import argparse
import asyncio
import sys

from bleak import BleakClient, BleakScanner

ADDRESS = "80:AC:C8:68:75:8B"
CHAR_WRITE = "0000a031-0000-1000-8000-00805f9b34fb"
CHAR_NOTIFY = "0000f031-0000-1000-8000-00805f9b34fb"

CMD_STATUS = 0x10
CMD_POWER = 0x11
CMD_PRESET = 0x12
CMD_BRIGHTNESS = 0x13
CMD_COLOR = 0x15
CMD_SPEED = 0x16

COLORS = {
    "red": (0xFF, 0x00, 0x00),
    "orange": (0xFF, 0x45, 0x00),
    "yellow": (0xFF, 0xFF, 0x00),
    "green": (0x00, 0xFF, 0x00),
    "cyan": (0x00, 0xFF, 0xFF),
    "blue": (0x00, 0x00, 0xFF),
    "purple": (0x80, 0x00, 0xFF),
    "magenta": (0xFF, 0x00, 0xFF),
    "pink": (0xFF, 0x40, 0x80),
    "white": (0xFF, 0xFF, 0xFF),
}

ATTEMPTS = 3
SCAN_TIMEOUT = 15.0
CONNECT_TIMEOUT = 20.0


def crc16_modbus(data):
    crc = 0xFFFF
    for byte in data:
        crc ^= byte
        for _ in range(8):
            crc = (crc >> 1) ^ 0xA001 if crc & 1 else crc >> 1
    return crc


def frame(cmd, payload=b""):
    body = bytes([0xA0, cmd, len(payload) + 3]) + bytes(payload)
    return body + crc16_modbus(body).to_bytes(2, "little")


# The trailing 30 47 is a constant the vendor app sends; it is not a nonce.
HANDSHAKE = (
    frame(0x00, b"CCHIP"),
    frame(0x01, b"CCHIP\x30\x47"),
    frame(CMD_STATUS, b"\x01"),
)


def parse_color(text):
    if text.lower() in COLORS:
        return COLORS[text.lower()]
    hexpart = text.lstrip("#")
    if len(hexpart) != 6:
        raise ValueError(f"expected a name from {sorted(COLORS)} or #rrggbb, got {text!r}")
    return tuple(int(hexpart[i : i + 2], 16) for i in (0, 2, 4))


def clamp_percent(value, low=0):
    number = int(value)
    if not low <= number <= 100:
        raise ValueError(f"expected {low}-100, got {number}")
    return number


class Strip:
    """One connected session: handshake, then any number of commands."""

    def __init__(self, client):
        self.client = client
        self.status = None
        self.acks = []

    def _on_notify(self, _handle, data):
        # a1 10 11 <14 bytes> is the status report; a1 <cmd> 04 <ok> is a
        # per-command ack, which is the only feedback most commands produce.
        if len(data) >= 19 and data[0:3] == b"\xa1\x10\x11":
            self.status = data[3:-2]
        elif len(data) >= 4 and data[0] == 0xA1:
            self.acks.append((data[1], data[3]))

    async def send(self, cmd, payload=b"", settle=0.4):
        self.acks.clear()
        await self.client.write_gatt_char(CHAR_WRITE, frame(cmd, payload), response=True)
        await asyncio.sleep(settle)
        for ack_cmd, ok in self.acks:
            if ack_cmd == cmd and ok != 1:
                raise RuntimeError(f"strip rejected command 0x{cmd:02x}")

    async def refresh(self):
        self.status = None
        await self.send(CMD_STATUS, b"\x01", settle=0.2)
        for _ in range(20):
            if self.status is not None:
                return self.status
            await asyncio.sleep(0.15)
        raise RuntimeError("strip did not report status")


async def session(action):
    device = await BleakScanner.find_device_by_address(ADDRESS, timeout=SCAN_TIMEOUT)
    if device is None:
        raise RuntimeError(
            f"{ADDRESS} is not advertising -- it stops advertising while a phone is connected"
        )

    async with BleakClient(device, timeout=CONNECT_TIMEOUT) as client:
        strip = Strip(client)
        await client.start_notify(CHAR_NOTIFY, strip._on_notify)
        for handshake_frame in HANDSHAKE:
            await client.write_gatt_char(CHAR_WRITE, handshake_frame, response=True)
            await asyncio.sleep(0.2)
        return await action(strip)


async def with_retries(action):
    for attempt in range(1, ATTEMPTS + 1):
        try:
            return await session(action)
        except Exception as exc:
            print(f"attempt {attempt}/{ATTEMPTS} failed: {type(exc).__name__}: {exc}", flush=True)
            if attempt == ATTEMPTS:
                return None
            await asyncio.sleep(2 * attempt)


def build_action(args):
    if args.command in ("on", "off"):
        want = 1 if args.command == "on" else 0

        async def action(strip):
            await strip.send(CMD_POWER, bytes([want]))
            status = await strip.refresh()
            if status[0] != want:
                raise RuntimeError(f"strip still reports power={status[0]}")
            return f"strip is now {args.command}"

    elif args.command == "color":
        rgb = parse_color(args.value)

        async def action(strip):
            # Fourth byte is a constant the app always sends alongside RGB.
            await strip.send(CMD_COLOR, bytes(rgb) + b"\xff")
            return f"color set to #{rgb[0]:02x}{rgb[1]:02x}{rgb[2]:02x}"

    elif args.command == "brightness":
        level = clamp_percent(args.value)

        async def action(strip):
            await strip.send(CMD_BRIGHTNESS, bytes([level]))
            return f"brightness set to {level}"

    elif args.command == "speed":
        level = clamp_percent(args.value, low=1)

        async def action(strip):
            await strip.send(CMD_SPEED, bytes([level]))
            return f"speed set to {level}"

    elif args.command == "preset":
        preset_id = int(args.value, 0)
        flag = int(args.flag, 0)

        async def action(strip):
            await strip.send(CMD_PRESET, bytes([preset_id, flag]))
            return f"preset {preset_id} selected"

    elif args.command == "status":

        async def action(strip):
            s = await strip.refresh()
            # Layout confirmed by setting each field and re-reading:
            # 0 power, 1-2 preset, 3 brightness, 4 speed, 6-8 RGB.
            return (
                f"power={'on' if s[0] else 'off'} "
                f"brightness={s[3]} speed={s[4]} "
                f"color=#{s[6]:02x}{s[7]:02x}{s[8]:02x} "
                f"preset=0x{s[1]:02x}"
            )

    return action


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("on", help="turn the strip on")
    sub.add_parser("off", help="turn the strip off")
    sub.add_parser("status", help="report current power and brightness")
    sub.add_parser("color", help="set colour").add_argument("value", help="name or #rrggbb")
    sub.add_parser("brightness", help="set brightness").add_argument("value", help="0-100")
    sub.add_parser("speed", help="set effect speed").add_argument("value", help="1-100")
    preset = sub.add_parser("preset", help="select a built-in preset")
    preset.add_argument("value", help="preset id, e.g. 7 or 0x1c")
    preset.add_argument("--flag", default="0xff", help="preset variant byte (default 0xff)")

    args = parser.parse_args()
    try:
        action = build_action(args)
    except ValueError as exc:
        print(exc, file=sys.stderr)
        return 2

    result = asyncio.run(with_retries(action))
    if result is None:
        return 1
    print(result, flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
