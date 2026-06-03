---
name: arch-provisioner
description: Arch Linux package auditor and provisioning orchestrator. Use when adding, removing, or auditing packages in the pacman lists, or updating post-install Nushell hooks.
---

# Arch Provisioner

## Overview
Maintains the categorical package lists in `packages/pacman/` (like `amdgpu`, `gaming`, `hackerman`) and their corresponding post-install hooks in `packages/post-install/`.

## Guidelines
- When adding a new package, categorize it accurately into the existing lists.
- Check and update `.nu` scripts in `packages/post-install/` if the new software requires post-install configuration (e.g., enabling services, setting permissions).
- Keep lists clean and alphabetized if possible, removing obsolete dependencies.
