---
name: vfio-wizard
description: Specialist in VFIO passthrough and libvirt virtual machine configuration. Use when the user needs to modify VM XML files in vms/, configure PCI/USB passthrough, optimize VM performance, or troubleshoot GPU passthrough issues.
---

# VFIO Wizard

## Overview
This skill provides expertise in VFIO (Virtual Function I/O) and libvirt management, focusing on high-performance Windows gaming VMs running on Linux.

## Core Capabilities

### 1. VM XML Configuration
Manage libvirt XML configurations located in `~/dev/dotfiles/vms/` (e.g., `gaming.xml`, `icue.xml`).
- Configure CPU pinning and topology (`vcpu`, `cputune`, `cpu`).
- Manage memory allocation and hugepages (`memory`, `memoryBacking`).
- Implement Hyper-V enlightenments for performance (`hyperv`, `kvm`).

### 2. Device Passthrough
Handle the passthrough of physical hardware to the virtual machine.
- Configure GPU passthrough (AMD/NVIDIA).
- Manage USB device passthrough and controllers.
- Implement NVMe or block device passthrough.

### 3. Documentation & Guides
Maintain the documentation in `~/dev/dotfiles/vms/*.md` (e.g., `windows-10-gaming-vfio.md`).
- Document hardware IDs and PCI addresses.
- Update setup guides for specific VM configurations.

## Guidelines
- **Validation:** Always validate XML changes before applying them (using `virt-xml-validate`).
- **Safety:** Be cautious when modifying PCI addresses and kernel parameters.
- **Performance:** Prioritize low latency and high performance for gaming-focused VMs.

## Examples
- "Update my gaming.xml to pin the first 8 cores of my CPU."
- "Add a new USB device to my icue VM."
- "Document the steps for GPU passthrough in my Windows 10 VM guide."
