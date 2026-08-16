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
command until the two-frame "CCHIP" handshake completes.

The strip accepts a single BLE connection at a time, and each connect costs a
few seconds. So the normal deployment is `ledstrip.py daemon` (run by
ledstrip.service), which holds the connection open and serves commands over a
unix socket. Every other subcommand is a thin client: it talks to that socket if
it exists, and otherwise falls back to connecting directly, so ad-hoc use still
works with no daemon running.
"""

import argparse
import asyncio
import os
import shlex
import signal
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

def _socket_dirs():
    """Where the daemon socket may live, most specific first.

    /run/ledstrip is systemd's RuntimeDirectory for the packaged unit; the
    XDG path is what an ad-hoc `ledstrip.py daemon` in a login session uses.
    """
    dirs = ["/run/ledstrip"]
    runtime = os.environ.get("XDG_RUNTIME_DIR")
    if runtime:
        dirs.append(runtime)
    dirs.append("/tmp")
    return dirs


def server_socket_path():
    explicit = os.environ.get("LEDSTRIP_SOCKET")
    if explicit:
        return explicit
    for directory in _socket_dirs():
        if os.path.isdir(directory) and os.access(directory, os.W_OK):
            return os.path.join(directory, "ledstrip.sock")
    raise RuntimeError("no writable directory for the socket")


def client_socket_path():
    explicit = os.environ.get("LEDSTRIP_SOCKET")
    candidates = (
        [explicit]
        if explicit
        else [os.path.join(d, "ledstrip.sock") for d in _socket_dirs()]
    )
    for path in candidates:
        if os.path.exists(path):
            return path
    return None

SCAN_TIMEOUT = 15.0
CONNECT_TIMEOUT = 20.0
ATTEMPTS = 3


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
    try:
        return tuple(int(hexpart[i : i + 2], 16) for i in (0, 2, 4))
    except ValueError:
        raise ValueError(f"not a hex colour: {text!r}") from None


def parse_percent(value, low=0):
    try:
        number = int(value)
    except ValueError:
        raise ValueError(f"expected a number, got {value!r}") from None
    if not low <= number <= 100:
        raise ValueError(f"expected {low}-100, got {number}")
    return number


def describe(status):
    # Layout confirmed by setting each field and reading it back:
    # 0 power, 1-2 preset, 3 brightness, 4 speed, 6-8 RGB.
    return (
        f"power={'on' if status[0] else 'off'} "
        f"brightness={status[3]} speed={status[4]} "
        f"color=#{status[6]:02x}{status[7]:02x}{status[8]:02x} "
        f"preset=0x{status[1]:02x}"
    )


class Strip:
    """A connected strip. One instance per BLE connection."""

    def __init__(self, client):
        self.client = client
        self.status = None
        self.acks = []

    def _on_notify(self, _handle, data):
        # a1 10 11 <14 bytes> is a status report; a1 <cmd> 04 <ok> is a per-command
        # ack. Preset changes are never pushed, so status must be polled.
        if len(data) >= 19 and data[0:3] == b"\xa1\x10\x11":
            self.status = data[3:-2]
        elif len(data) >= 4 and data[0] == 0xA1:
            self.acks.append((data[1], data[3]))

    async def handshake(self):
        await self.client.start_notify(CHAR_NOTIFY, self._on_notify)
        for handshake_frame in HANDSHAKE:
            await self.client.write_gatt_char(CHAR_WRITE, handshake_frame, response=True)
            await asyncio.sleep(0.2)

    async def send(self, cmd, payload=b"", settle=0.4):
        self.acks.clear()
        await self.client.write_gatt_char(CHAR_WRITE, frame(cmd, payload), response=True)
        if not settle:
            return
        await asyncio.sleep(settle)
        for ack_cmd, ok in self.acks:
            if ack_cmd == cmd and ok != 1:
                raise RuntimeError(f"strip rejected command 0x{cmd:02x}")

    async def refresh(self):
        self.status = None
        await self.send(CMD_STATUS, b"\x01", settle=0)
        for _ in range(20):
            await asyncio.sleep(0.15)
            if self.status is not None:
                return self.status
        raise RuntimeError("strip did not report status")


async def open_strip():
    """Scan, connect, and handshake. Caller owns the returned client."""
    device = await BleakScanner.find_device_by_address(ADDRESS, timeout=SCAN_TIMEOUT)
    if device is None:
        raise RuntimeError(
            f"{ADDRESS} is not advertising -- it stops advertising while something else is connected"
        )
    client = BleakClient(device, timeout=CONNECT_TIMEOUT)
    await client.connect()
    strip = Strip(client)
    await strip.handshake()
    return client, strip


class Server:
    """Holds the BLE connection and serves commands over a unix socket."""

    def __init__(self):
        self.client = None
        self.strip = None
        self.lock = asyncio.Lock()
        self.effect = None

    async def ensure_connected(self):
        if self.client is not None and self.client.is_connected:
            return
        if self.client is not None:
            try:
                await self.client.disconnect()
            except Exception:
                pass
            self.client = self.strip = None
        delay = 2
        while True:
            try:
                self.client, self.strip = await open_strip()
                print("connected to strip", flush=True)
                return
            except Exception as exc:
                # Keep retrying rather than exiting: at boot the adapter may not
                # be ready, and the strip is unreachable while a phone holds it.
                print(f"connect failed: {exc}; retrying in {delay}s", flush=True)
                await asyncio.sleep(delay)
                delay = min(delay * 2, 60)

    async def stop_effect(self):
        if self.effect is not None:
            self.effect.cancel()
            try:
                await self.effect
            except (asyncio.CancelledError, Exception):
                pass
            self.effect = None

    async def _flash(self, palette, interval):
        index = 0
        while True:
            red, green, blue = palette[index % len(palette)]
            async with self.lock:
                await self.ensure_connected()
                await self.strip.send(CMD_COLOR, bytes((red, green, blue)) + b"\xff", settle=0)
            await asyncio.sleep(interval)
            index += 1

    async def dispatch(self, argv):
        if not argv:
            return "empty command"
        verb, rest = argv[0], argv[1:]

        if verb == "status":
            async with self.lock:
                await self.ensure_connected()
                return describe(await self.strip.refresh())

        if verb == "stop":
            await self.stop_effect()
            return "effect stopped"

        if verb == "flash":
            options = [a for a in rest if a.startswith("--interval=")]
            names = [a for a in rest if not a.startswith("--")]
            interval = float(options[0].split("=", 1)[1]) if options else 0.5
            if len(names) < 2:
                return "flash needs at least two colours"
            palette = [parse_color(n) for n in names]
            await self.stop_effect()
            async with self.lock:
                await self.ensure_connected()
                await self.strip.send(CMD_POWER, b"\x01")
            self.effect = asyncio.create_task(self._flash(palette, interval))
            return f"flashing {' '.join(names)} every {interval}s"

        # Everything below is a one-shot setting, so any running effect would
        # immediately overwrite it.
        await self.stop_effect()
        async with self.lock:
            await self.ensure_connected()
            if verb in ("on", "off"):
                want = 1 if verb == "on" else 0
                await self.strip.send(CMD_POWER, bytes([want]))
                return f"strip is now {verb}"
            if verb == "color":
                rgb = parse_color(rest[0])
                await self.strip.send(CMD_COLOR, bytes(rgb) + b"\xff")
                return f"color set to #{rgb[0]:02x}{rgb[1]:02x}{rgb[2]:02x}"
            if verb == "brightness":
                level = parse_percent(rest[0])
                await self.strip.send(CMD_BRIGHTNESS, bytes([level]))
                return f"brightness set to {level}"
            if verb == "speed":
                level = parse_percent(rest[0], low=1)
                await self.strip.send(CMD_SPEED, bytes([level]))
                return f"speed set to {level}"
            if verb == "preset":
                preset_id = int(rest[0], 0)
                flag = int(rest[1], 0) if len(rest) > 1 else 0xFF
                await self.strip.send(CMD_PRESET, bytes([preset_id, flag]))
                return f"preset {preset_id} selected"
        return f"unknown command: {verb}"

    async def _handle(self, reader, writer):
        try:
            line = await reader.readline()
            try:
                reply = await self.dispatch(shlex.split(line.decode().strip()))
            except Exception as exc:
                reply = f"error: {type(exc).__name__}: {exc}"
            writer.write(reply.encode() + b"\n")
            await writer.drain()
        finally:
            writer.close()

    async def serve(self):
        socket_path = server_socket_path()
        if os.path.exists(socket_path):
            os.unlink(socket_path)
        server = await asyncio.start_unix_server(self._handle, path=socket_path)
        os.chmod(socket_path, 0o600)
        print(f"listening on {socket_path}", flush=True)

        await self.ensure_connected()
        async with self.lock:
            await self.strip.send(CMD_POWER, b"\x01")
        print("strip is now on", flush=True)

        stop = asyncio.Event()
        loop = asyncio.get_running_loop()
        for sig in (signal.SIGTERM, signal.SIGINT):
            loop.add_signal_handler(sig, stop.set)
        await stop.wait()

        print("shutting down", flush=True)
        server.close()
        await self.stop_effect()
        try:
            async with self.lock:
                if self.client is not None and self.client.is_connected:
                    await self.strip.send(CMD_POWER, b"\x00")
                    print("strip is now off", flush=True)
                    await self.client.disconnect()
        finally:
            if os.path.exists(socket_path):
                os.unlink(socket_path)


async def send_to_daemon(socket_path, argv):
    reader, writer = await asyncio.open_unix_connection(socket_path)
    writer.write(shlex.join(argv).encode() + b"\n")
    await writer.drain()
    reply = await reader.readline()
    writer.close()
    return reply.decode().strip()


async def run_direct(argv):
    """Fallback when no daemon is running: one connection, one command."""
    last = None
    for attempt in range(1, ATTEMPTS + 1):
        client = None
        try:
            client, strip = await open_strip()
            server = Server()
            server.client, server.strip = client, strip
            return await server.dispatch(argv)
        except Exception as exc:
            last = exc
            print(f"attempt {attempt}/{ATTEMPTS} failed: {type(exc).__name__}: {exc}", flush=True)
            if attempt < ATTEMPTS:
                await asyncio.sleep(2 * attempt)
        finally:
            if client is not None:
                try:
                    await client.disconnect()
                except Exception:
                    pass
    raise SystemExit(1) from last


def main():
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("daemon", help="hold the connection and serve commands (used by ledstrip.service)")
    sub.add_parser("on", help="turn the strip on")
    sub.add_parser("off", help="turn the strip off")
    sub.add_parser("status", help="report power, brightness, speed, colour, preset")
    sub.add_parser("stop", help="stop a running effect")
    sub.add_parser("color", help="set colour").add_argument("value", help="name or #rrggbb")
    sub.add_parser("brightness", help="set brightness").add_argument("value", help="0-100")
    sub.add_parser("speed", help="set effect speed").add_argument("value", help="1-100")
    flash = sub.add_parser("flash", help="alternate colours until stopped")
    flash.add_argument("colors", nargs="+", help="two or more colours to cycle")
    flash.add_argument("--interval", default="0.5", help="seconds per colour (default 0.5)")
    preset = sub.add_parser("preset", help="select a built-in preset")
    preset.add_argument("value", help="preset id, e.g. 7 or 0x1c")
    preset.add_argument("--flag", default="0xff", help="preset variant byte (default 0xff)")

    args = parser.parse_args()

    if args.command == "daemon":
        try:
            asyncio.run(Server().serve())
        except KeyboardInterrupt:
            pass
        return 0

    argv = [args.command]
    if args.command == "flash":
        argv += args.colors + [f"--interval={args.interval}"]
    elif args.command == "preset":
        argv += [args.value, args.flag]
    elif hasattr(args, "value"):
        argv.append(args.value)

    socket_path = client_socket_path()
    if socket_path is not None:
        print(asyncio.run(send_to_daemon(socket_path, argv)), flush=True)
        return 0

    print(asyncio.run(run_direct(argv)), flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
