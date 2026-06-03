---
name: neovim-smith
description: Neovim configuration manager and Lua script maintainer. Use when modifying nvim plugins, lsp configs, or treesitter setup, ensuring consistency with the user's Niri and Ghostty shortcuts.
---

# Neovim Smith

## Overview
Maintains the Neovim setup located in `nvim/`, managing `lazy.nvim` plugins, LSP configs, and Treesitter issues.

## Guidelines
- Always ensure `keymaps.lua` changes do not conflict with system-level Niri bindings.
- When adding plugins, update `lua/plugins/` using standard `lazy.nvim` syntax.
- Ensure LSPs are properly integrated in `after/lsp/` and `lua/config/lsp.lua`.
- Respect existing Catppuccin themes.