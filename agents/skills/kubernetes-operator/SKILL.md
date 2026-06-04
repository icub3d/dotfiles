---
name: kubernetes-operator
description: Kubernetes cluster operator for the Marshian Galaxy home lab. Use when managing workloads, namespaces, node operations, Cilium networking, or kubectl/helm workflows on the k8s0–k8s4 cluster.
---

# Kubernetes Operator

## Overview
This skill manages the Marshian Galaxy Kubernetes cluster — a multi-node home lab running on Alpine Linux VMs with Cilium for networking. It covers day-to-day kubectl operations, workload management, node health, and the custom Nushell helpers in `nushell/bin/kubernetes.nu`.

## Cluster Topology

| Node | Role | OS |
| :--- | :--- | :--- |
| `k8s0`, `k8s1`, `k8s2` | Control Plane + Worker | Alpine Linux |
| `k8s3`, `k8s4` | Worker | Alpine Linux |
| `srv2` | NFS / Minecraft services VM | Alpine Linux |
| `wireguard` | VPN gateway VM | Alpine Linux |
| `pihole` | DNS / ad-blocker VM | Debian |

Service VIP accessibility is verified via `https://git.marsh.gg` (Cilium load balancer).

## Core Capabilities

### 1. Node Operations
- Check cluster health: `kubectl get nodes -o wide`
- Cordon before maintenance: `kubectl cordon <node>`
- Drain safely: `kubectl drain <node> --ignore-daemonsets --delete-emptydir-data --force`
- Uncordon after: `kubectl uncordon <node>`
- For reboots of the full cluster, delegate to the `galaxy-rebooter` skill.

### 2. Workload Management
- Deploy/update: `kubectl apply -f <manifest>` or `helm upgrade --install`
- Rollout status: `kubectl rollout status deployment/<name> -n <ns>`
- Rollback: `kubectl rollout undo deployment/<name>`
- Logs: `kubectl logs -n <ns> <pod> --tail=100 -f`

### 3. Nushell Kubernetes Helpers
The file `nushell/bin/kubernetes.nu` contains custom commands. When editing:
- Follow Nushell typing conventions (see `nushell-orchestrator` skill).
- Keep outputs as structured tables so they pipe naturally into `where`, `sort-by`, etc.
- Avoid shelling out to `jq`; use Nushell's `from json` instead.

### 4. Cilium Networking
- Cilium is the CNI — use `cilium status` and `cilium connectivity test` to diagnose network issues.
- The cluster VIP for external services resolves via Cilium's LB; verify with `curl -s https://git.marsh.gg`.
- When adding new `LoadBalancer` services, ensure `externalTrafficPolicy` and IP pool annotations match the existing pattern.

### 5. Control Plane API Transience
During control plane node reboots, the Kubernetes API becomes temporarily unavailable. Any script that polls `kubectl get node` must:
- Wrap in `try { ... } catch { ... }` (Nushell) or equivalent retry logic.
- Wait for SSH to return before attempting kubectl commands against that node.
- Expect transient auth/refused/forbidden errors — treat them as retry triggers, not hard failures.

### 6. Common Troubleshooting
- Pod stuck `Pending`: check `kubectl describe pod <name>` for resource/affinity/taint issues.
- Node `NotReady`: check `kubectl describe node <name>` and SSH in to check kubelet logs (`rc-service kubelet status`).
- DNS failures: check pihole is up; `kubectl exec -it <pod> -- nslookup kubernetes.default`.

## Examples
- "Show me all pods across all namespaces that aren't running."
- "Add a new namespace for my monitoring stack and deploy a Helm chart into it."
- "One of the workers is NotReady — help me diagnose."
- "Update the kubernetes.nu helper to show resource requests alongside pod status."
