---
name: pihole-health
description: Health check and usage report for the two Pi-holes in the Marshian Galaxy (the Pi at 192.168.86.29 and the k8s replica at 192.168.86.194). Use when asked whether the Pi-holes are in sync, whether DNS/blocking works, or for a summary of blocked requests and DNS usage.
---

# Pi-hole Health

## Overview

Two Pi-hole v6 instances serve the LAN; the router hands out both.

| | Primary | Replica |
| :--- | :--- | :--- |
| Where | Raspberry Pi 4 (`ssh pihole`, `sudo -n`) | k8s namespace `pihole`, Deployment `pihole`, pinned to `k8s4` |
| DNS / web | 192.168.86.29 | 192.168.86.194 (Cilium LB IP) |
| Role | source of truth: edit lists and settings here | overwritten by `nebula-sync` every 6 h |

`nebula-sync` (Deployment `nebula-sync`, same namespace) does a *selective*
sync from the Pi: adlists, groups, domain rules, clients, local DNS records,
upstreams, resolver/database/misc config. It deliberately skips
`dns.listeningMode`/`dns.interface` (the replica needs `ALL`). Manifests and
setup notes: `~/dev/marshians/k8s/pihole/README.md`.

## The one command

```bash
nu helpers/pihole-health.nu            # report
nu helpers/pihole-health.nu --hours 6  # shorter usage window (default 24h)
nu helpers/pihole-health.nu --json     # structured record
```

Run from the dotfiles root. It needs `ssh pihole`, `kubectl`, and `dig` on
this machine, and takes about 10 seconds.

### What it checks

1. **Sync** — compares adlists (id, URL, enabled), gravity domain count, and
   group/domain-rule/client counts on both instances, and reads the last
   `Sync completed` / `Sync failed` line from the nebula-sync log.
   `in_sync=true` plus `nebula-sync last run: ok` is healthy.
2. **Resolve** — against each IP: a normal lookup, `ad.doubleclick.net`
   must be `0.0.0.0`, `forgejo.sw.marsh.gg` must be `192.168.86.192`
   (wildcard from dnsmasq.d / ConfigMap), `k8s` must be `192.168.86.38`
   (the API server name the kubelets use), and one TCP query.
3. **Usage** — per instance over the window: total queries, blocked count
   and percentage, distinct clients, top 10 blocked domains, top 10
   clients (with their blocked counts), top 10 permitted domains.

### How to report

Lead with the verdict: in sync or not, both resolving or not. Then give the
usage numbers as a short table (queries / blocked / % / clients per
instance) and the handful of top blocked domains and busiest clients.
Mozilla telemetry and `googleads` entries are normal background noise; call
out anything that looks like malware/phishing (Hagezi TIF hits) or a single
client with an unusually high block rate. Name clients by IP unless the
query log already shows a hostname. On the replica, `10.0.x.x` clients are
cluster pods: CoreDNS forwards to the node's resolvers and k8s4 hands those
queries to the replica directly. `127.0.0.1` is the instance's own lookups
(list downloads, update checks).

## When something is off

| Symptom | Likely cause | Fix |
| :--- | :--- | :--- |
| `in_sync=false`, gravity counts differ | Pi got a list change and the replica has not synced yet, or gravity is still running on the replica (2.3M domains takes ~1 min) | Wait, or force a run: `kubectl -n pihole rollout restart deploy/nebula-sync` (it syncs on start) |
| nebula-sync `FAILED` with 401/403 from the Pi | App password invalid, or `webserver.api.app_sudo` turned off on the Pi | Regenerate per `k8s/pihole/README.md` (`pihole api auth/app`, store hash, `app_sudo true`, restart FTL), update secret `pihole-sync` |
| Replica resolves nothing | Pod not running on `k8s4`, or `dns.listeningMode` got set to LOCAL | `kubectl -n pihole get pods -o wide`; `kubectl -n pihole exec deploy/pihole -- pihole-FTL --config dns.listeningMode` must be `ALL` |
| Wildcard fails on replica only | ConfigMap `pihole-dnsmasq` out of step with the Pi's `/etc/dnsmasq.d/05-wildcard-sw.conf` | Edit the ConfigMap in `pihole.yaml`, apply, restart the pod |
| Pi resolves nothing | Pi down or FTL stopped | `ssh pihole sudo -n systemctl status pihole-FTL`; the LAN keeps working on the replica meanwhile |
| Blocked status codes | Script counts FTL statuses 1,4–11,15,16,18 as blocked (gravity, regex, denylist, external, CNAME variants, DB busy, special domains, EDE15); 17 = cache-stale is *not* a block | — |

## Useful one-offs

```bash
# Live query log on either instance
ssh pihole sudo -n pihole -t
kubectl -n pihole exec deploy/pihole -- pihole -t

# Replica adlists / config
kubectl -n pihole exec deploy/pihole -- pihole-FTL sqlite3 /etc/pihole/gravity.db "select id,address,number from adlist"

# Force gravity on the Pi after adding a list (then let nebula-sync carry it over)
ssh pihole sudo -n pihole -g
```

Remote shells are nushell: wrap anything with bash syntax in `bash -c '...'`,
or pipe a script to `ssh <host> "bash -s"`.
