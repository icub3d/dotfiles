---
name: catppuccin-sync
description: Specialist in synchronizing Catppuccin color schemes across all dotfiles and applications. Use when the user needs to update themes for Alacritty, btop, Neovim, VSCode, or the system UI to Mocha (dark) or Latte (light) variants.
---

# Catppuccin Sync

## Overview
This skill focuses on the Catppuccin color palette and its application across the user's entire system. It ensures a consistent visual experience by managing themes for multiple applications.

## Core Capabilities

### 1. Application Theming
Manage Catppuccin themes for various applications in `~/dev/dotfiles/`.
- **Alacritty:** Update `dotfiles/.config/alacritty/catppuccin-mocha.toml`.
- **btop:** Manage `dotfiles/.config/btop/themes/catppuccin_mocha.theme`.
- **Neovim:** Configure colorscheme in `nvim/lua/plugins/colors.lua`.
- **VSCode:** Update theme settings in `vscode-settings-vim.json` and `.vscode/settings.json`.
- **Gnome Shell:** Modify `.themes/marshians/gnome-shell/gnome-shell.css` (user-specific variant).

### 2. Palette Variants
Switch between different Catppuccin flavors.
- **Mocha:** The default dark theme.
- **Latte:** The default light theme.
- **Frappé/Macchiato:** Alternate dark themes if needed.

### 3. Theme Generation
Assist in generating or porting Catppuccin palettes to new applications or configuration formats.

## Guidelines
- **Consistency:** Ensure that changing the primary flavor (e.g., from Mocha to Latte) propagates to all supported applications.
- **Accent Colors:** Respect the user's preferred accent color (e.g., Lavender, Rosewater, Mauve) where applicable.
- **Contrast:** Maintain high readability and contrast across different terminal and UI environments.

## Examples
- "Switch my entire system theme from Catppuccin Mocha to Latte."
- "Apply the Catppuccin Mocha palette to my new Kitty configuration."
- "Change the accent color of my Catppuccin theme to Mauve in Neovim and Alacritty."
