---
name: wireguard-configurator
description: WireGuard VPN configuration manager for the Marshian Galaxy. Use when adding/removing peers, rotating keys, editing interface config on the wireguard VM, or debugging VPN connectivity.
---

# WireGuard Configurator

## Overview
This skill manages the WireGuard VPN gateway that is part of the Marshian Galaxy home lab. The `wireguard` host is an Alpine Linux VM (SSH-accessible as `wireguard`) that acts as the VPN ingress point for remote access to the cluster and home network.

## Infrastructure Context
- **VPN Host**: `wireguard` VM (Alpine Linux), managed alongside `srv2` and `pihole`.
- **Config location on host**: `/etc/wireguard/wg0.conf` (or similar — verify with `ssh wireguard ls /etc/wireguard/`).
- **Cluster access**: WireGuard peers can reach the Kubernetes cluster and internal services after connecting.
- **DNS**: Pihole (`pihole` VM) handles DNS for connected peers.

## Core Capabilities

### 1. Peer Management
Adding a new peer:
1. **On the peer device**: generate a keypair: `wg genkey | tee privatekey | wg pubkey > publickey`
2. **On the wireguard host**: add to `[Peer]` section:
   ```ini
   [Peer]
   PublicKey = <peer-pubkey>
   AllowedIPs = <assigned-IP>/32
   ```
3. Apply without downtime: `ssh wireguard 'doas wg addconf wg0 <(echo "[Peer]...")'` or `doas wg syncconf wg0 /etc/wireguard/wg0.conf` after editing the file.

Removing a peer:
- Delete the `[Peer]` block from `wg0.conf`, then `doas wg syncconf wg0 /etc/wireguard/wg0.conf`.
- Verify removal: `ssh wireguard 'doas wg show'`.

### 2. Key Rotation
When rotating a peer's key (compromise or routine):
1. Generate new keypair on the peer device.
2. Update the `PublicKey` in the corresponding `[Peer]` block on the server.
3. Update the `PrivateKey` in the peer's local `[Interface]` block.
4. Sync the config: `doas wg syncconf wg0 /etc/wireguard/wg0.conf`.
5. Verify the new handshake: `doas wg show` should show a recent `latest handshake`.

### 3. Interface Configuration
The `[Interface]` section on the server typically includes:
```ini
[Interface]
Address = <VPN-subnet-gateway>/24
ListenPort = 51820
PrivateKey = <server-private-key>
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
```
- Alpine uses `rc-service wg-quick.wg0 restart` to apply interface-level changes (not just `syncconf`).
- Confirm IP forwarding is enabled: `sysctl net.ipv4.ip_forward` should return `1`.

### 4. Connectivity Debugging
- **Check active sessions**: `ssh wireguard 'doas wg show'` — inspect `latest handshake` timestamps.
- **No handshake**: firewall or port forwarding issue on the router; verify UDP 51820 is forwarded to the wireguard VM.
- **Connected but no traffic**: check `AllowedIPs` on both sides; check pihole DNS is reachable from the peer.
- **Reachability test**: from inside the VPN, `ping <cluster-node-IP>` or `curl https://git.marsh.gg`.

### 5. Rebooting the WireGuard VM
Delegate full reboot sequences to the `galaxy-rebooter` skill. For a targeted wireguard-only restart:
```nushell
ssh wireguard "doas reboot"
```
Wait for SSH to return, then verify `doas wg show` has active sessions restored.

## Examples
- "Add a new WireGuard peer for my phone."
- "Rotate the key for my laptop — it may be compromised."
- "I can connect to the VPN but can't reach the Kubernetes cluster."
- "Show me all active WireGuard peers and when they last connected."
