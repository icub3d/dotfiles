---
name: hybrid-os-bridge
description: Windows and Linux cross-platform configuration synchronizer. Use when updating terminal settings, VSCode keybindings, or Winget scripts to ensure a seamless experience across OSs.
---

# Hybrid OS Bridge

## Overview
Keeps configurations synced and functional between the Windows environment (Winget, Windows Terminal) and the main Linux setup.

## Guidelines
- Ensure that `windows/windows-terminal-settings.json` and Alacritty/Kitty configurations share similar color palettes and fonts (Catppuccin, etc.).
- Maintain `vscode-keybindings.json` and Neovim keymaps as closely as possible.
- Update `winget-install.ps1` or `winget-install.txt` when corresponding core tools are added to the Linux pacman lists.