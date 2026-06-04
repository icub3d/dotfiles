---
name: rust-smith
description: Specialized in Rust toolchains, cargo config optimizations, crate profiling, build script setups, and memory/performance optimizations (including the cached crate memoization strategy). Use when developing or optimizing Rust projects.
---

# Rust Smith

## Overview
This skill provides deep expertise in the Rust ecosystem. It focuses on writing clean, idiomatic, high-performance Rust, configuring optimized cargo profiles, utilizing profiling and security tooling, and implementing efficient algorithms/caching strategies.

## Core Capabilities

### 1. Cargo Optimization
Configure and optimize `Cargo.toml` settings for development and production profiles:
- Define optimal release configurations (e.g., `opt-level`, `lto`, `codegen-units`, `panic`, and `strip`).
- Configure linkers like `mold` or `lld` in `.cargo/config.toml` to speed up local compilation times.
- Set up target-specific configuration profiles.

### 2. Memoization & Caching
Implement efficient memoization patterns, especially using the `cached` crate:
- **Mutable Arguments Caching:** When memoizing functions with `&mut` arguments, use the `cached` crate with a custom `key` type (e.g., `u64`) and a `convert` block to hash the mutable argument. This avoids cloning mutable data into the cache key.
- Custom state management and caching structures.

### 3. Profiling & Diagnostics
Inspect and diagnose Rust binaries:
- Check executable layout and imports using tools like `bingrep` (alias `objdump`) or standard `objdump`.
- Find size bottlenecks using `cargo bloat`.
- Clean up unused dependencies with `cargo udeps` and perform safety audits with `cargo deny`.

### 4. Build Scripts & Automation
Manage complex project setups:
- Draft robust `build.rs` scripts for code generation, linking C libraries, or injecting compile-time environment variables.
- Write cargo aliases for quick workflow tasks.

## Guidelines
- **Zero-Copy & Lifetimes:** Prioritize zero-copy parsing (`&str` or `&[u8]`) and proper lifetime scopes to avoid unnecessary allocations.
- **Safety First:** Avoid `unsafe` blocks unless absolutely necessary for performance-critical bottlenecks, and fully document safety invariants.
- **Linting:** Keep code compliant with modern Rust idioms using `cargo clippy`.

## Examples
- "Add a release profile to my Cargo.toml that prioritizes small binary size and strips debug symbols."
- "Show me how to cache a function that takes a mutable state reference without cloning the state."
- "Speed up my cargo build times by configuring mold in .cargo/config.toml."
- "Write a build.rs script that embeds the current git commit hash in the binary at compile time."
