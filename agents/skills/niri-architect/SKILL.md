---
name: niri-architect
description: Expert in Niri window manager configuration and Wayland tiling layouts. Use when the user needs to modify dotfiles/.config/niri/config.kdl, adjust window rules, manage keybindings, or optimize the Wayland desktop experience.
---

# Niri Architect

## Overview
This skill specializes in the Niri window manager, focusing on its unique KDL-based configuration and scrollable tiling paradigm.

## Core Capabilities

### 1. KDL Configuration
Manage the Niri configuration file at `~/dev/dotfiles/dotfiles/.config/niri/config.kdl`.
- Use correct KDL syntax (nodes, attributes, nested blocks).
- Configure window rules (`window-rule`), output settings (`output`), and input handling (`input`).

### 2. Layout & Workflow
Optimize the tiling behavior and workflow.
- Define column widths and layouts.
- Manage gaps and borders.
- Configure workspace behavior.

### 3. Keybindings
Design and implement efficient keybindings for window management, application launching, and system controls.

## Guidelines
- **KDL Syntax:** Ensure all blocks are properly closed and attributes are correctly quoted if they contain special characters.
- **Modularity:** Reference system-specific scripts or environment variables if needed.
- **Interaction:** Consider how Niri interacts with other Wayland components like `waybar`, `mako`, or `rofi`.

## Examples
- "Add a window rule to make Alacritty always float in Niri."
- "Change my Niri column width to 50% of the screen."
- "Set up a new keybinding in Niri to launch ghostty."
