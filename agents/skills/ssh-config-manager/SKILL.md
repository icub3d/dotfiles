---
name: ssh-config-manager
description: SSH config manager for the Marshian Galaxy multi-host setup. Use when adding/editing Host blocks, configuring ProxyJump chains, managing identities, or debugging SSH connectivity to cluster nodes, VMs, and git.marsh.gg.
---

# SSH Config Manager

## Overview
This skill manages `~/.ssh/config` for a multi-host home lab environment (the Marshian Galaxy). The current config is minimal (one block for `git.marsh.gg`), but the infrastructure includes many SSH targets that benefit from organized Host entries: Kubernetes nodes, VMs (srv2, wireguard, pihole), and external hosts accessed over WireGuard.

## Current Config Location
`~/.ssh/config` — single file, not currently tracked in dotfiles. Consider adding to `dotfiles/` and symlinking via `install.nu` if it doesn't contain machine-specific secrets.

## Known Hosts

| Host alias | Hostname / reach | Notes |
| :--- | :--- | :--- |
| `git.marsh.gg` | `git.marsh.gg` port 2222 | Gitea instance, user `git` |
| `k8s0`–`k8s4` | Internal IPs or hostnames | Alpine Linux, Kubernetes nodes |
| `srv2` | Internal VM | NFS / Minecraft, Alpine Linux |
| `wireguard` | Internal VM | VPN gateway, Alpine Linux |
| `pihole` | Internal VM | DNS / ad-blocker, Debian |

## Core Capabilities

### 1. Host Block Structure
```
Host <alias>
  HostName <ip-or-fqdn>
  User <username>
  Port <port>           # only if non-22
  IdentityFile ~/.ssh/<key>
  IdentitiesOnly yes    # prevents key leakage to unexpected hosts
```

Use `Host` with a short alias that matches what you type at the terminal. The full hostname goes in `HostName`.

### 2. ProxyJump / Bastion Chains
For hosts reachable only through another host (e.g., internal cluster nodes accessible only over WireGuard):
```
Host k8s*
  User <alpine-user>
  ProxyJump wireguard    # routes SSH through the wireguard VM
```
Or inline: `ssh -J wireguard k8s0`

### 3. Identity Management
- Keep separate keys per purpose: one for cluster nodes, one for git, one for external hosts.
- Use `IdentitiesOnly yes` on blocks with an explicit `IdentityFile` to prevent ssh-agent from trying unrelated keys (reduces auth failures on servers with `MaxAuthTries`).
- For hosts using `doas` (Alpine): ensure the remote user is in the `wheel` group; no SSH-specific config needed.

### 4. WireGuard-Dependent Hosts
Hosts inside the VPN subnet are only reachable when WireGuard is active. A good pattern:
```
Host k8s0
  HostName 10.x.y.z     # VPN-assigned IP
  User alpine-user
  IdentityFile ~/.ssh/galaxy_ed25519
  IdentitiesOnly yes
```
If WireGuard is down, SSH to these hosts will time out — that's expected behavior, not a config bug.

### 5. Multiplexing (ControlMaster)
For hosts you SSH into frequently (k8s nodes during reboots, debugging sessions):
```
Host k8s*
  ControlMaster auto
  ControlPath ~/.ssh/cm-%r@%h:%p
  ControlPersist 10m
```
This reuses a single TCP connection for multiple SSH sessions to the same host, significantly speeding up repeated connections.

### 6. Common Patterns for Alpine Linux Nodes
Alpine nodes use `doas` instead of `sudo` and may have a non-root default user. A typical block:
```
Host k8s0
  HostName k8s0.local    # or direct IP
  User josh
  IdentityFile ~/.ssh/galaxy_ed25519
  IdentitiesOnly yes
  StrictHostKeyChecking accept-new   # for home lab nodes that get reinstalled
```

`StrictHostKeyChecking accept-new` auto-accepts new host keys but rejects changed ones — safer than `no` for home lab use.

### 7. Tracking in Dotfiles
If `~/.ssh/config` contains no machine-specific secrets:
1. Move it to `dotfiles/.ssh/config`.
2. Add a symlink entry in `install.nu` (see `dotfiles-guardian` skill).
3. Ensure `dotfiles/.ssh/` has mode `700` after symlinking: `chmod 700 ~/.ssh`.

If it contains inline keys or per-machine paths, keep it untracked and document the expected structure in a `dotfiles/.ssh/config.example`.

## Examples
- "Add SSH host entries for all five Kubernetes nodes with ProxyJump through wireguard."
- "I keep getting host key warnings for k8s nodes after reinstalls — fix the config."
- "Set up ControlMaster for the cluster nodes to speed up my reboot scripts."
- "Add the git.marsh.gg block to dotfiles and wire up the symlink."
