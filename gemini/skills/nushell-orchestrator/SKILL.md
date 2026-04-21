---
name: nushell-orchestrator
description: Specialized for Nushell scripting, configuration management, and shell automation. Use when the user needs to modify nushell/config.nu, nushell/env.nu, create helper scripts in helpers/*.nu, or automate tasks using Nushell's structured data and pipeline features.
---

# Nushell Orchestrator

## Overview
This skill provides expertise in Nushell (nu), a modern shell with a structured data approach. It focuses on maintaining the user's Nushell environment and creating robust, type-safe scripts for system automation.

## Core Capabilities

### 1. Configuration Management
Manage the core Nushell configuration files located in `~/dev/dotfiles/nushell/`.
- `config.nu`: Main configuration, aliases, and hooks.
- `env.nu`: Environment variables and path setup.
- `linux.nu`, `macos.nu`, `windows.nu`: Platform-specific overrides.

### 2. Scripting & Automation
Create and maintain helper scripts in `~/dev/dotfiles/helpers/` (e.g., `liquidcfg.nu`, `wow.nu`, `setup-aoc-recording.nu`).
- Use Nushell's strong typing for script parameters (`def main [arg: string, --flag: int]`).
- Leverage structured data (JSON, YAML, TOML) parsing and generation.
- Utilize external commands safely using Nushell's `^` prefix or `run-external`.

### 3. Dotfiles Installation
Maintain `install.nu` in the root directory, which handles symlinking and environment setup across different platforms.

## Guidelines
- **Prefer Tables:** Use Nushell's built-in table manipulation (`where`, `sort-by`, `select`, `get`) instead of `grep`, `sed`, or `awk`.
- **Type Safety:** Always define types for function parameters and return values in scripts.
- **Error Handling:** Use `try { ... } catch { ... }` blocks for fragile operations like network requests or file system changes.
- **Completions:** Implement custom completions for scripts to improve the CLI experience.

## Examples
- "Add an alias to my nushell config to list files by size."
- "Create a Nushell script in helpers/ to automate my liquidctl profile switching."
- "Update install.nu to support a new configuration directory."
