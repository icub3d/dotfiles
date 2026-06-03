---
name: dotfiles-guardian
description: Dotfiles integrity and installation logic manager. Use when updating `install.nu`, managing symlinks, or modifying cross-platform configuration branching.
---

# Dotfiles Guardian

## Overview
Handles the core dotfiles installation logic in `install.nu`. It focuses on ensuring accurate symlinking, handling environment transitions, and protecting secrets.

## Guidelines
- Always verify path existence and `is-symlink` conditions before overriding files.
- Ensure Windows vs Linux vs macOS branches remain functional and isolated.
- Do not commit sensitive data or tokens. Check `.gitignore` when adding new tool configurations.