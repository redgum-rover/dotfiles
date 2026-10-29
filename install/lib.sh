#!/usr/bin/env bash
# Shared helpers for all install scripts. Sourced, not executed.

set -euo pipefail

# Colours
c_info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
c_ok()   { printf '\033[1;32m  ✓\033[0m %s\n' "$*"; }
c_warn() { printf '\033[1;33m  !\033[0m %s\n' "$*"; }
c_skip() { printf '\033[1;90m  ·\033[0m %s\n' "$*"; }

have() { command -v "$1" >/dev/null 2>&1; }

# Detect platform: sets PLATFORM to "wsl" or "linux" unless already set by flag.
detect_platform() {
  if [ -n "${PLATFORM:-}" ]; then return; fi
  if grep -qi microsoft /proc/version 2>/dev/null || [ -n "${WSL_DISTRO_NAME:-}" ]; then
    PLATFORM="wsl"
  else
    PLATFORM="linux"
  fi
}

# Architecture helpers (amd64/arm64) for release downloads.
arch_deb() { dpkg --print-architecture; }
arch_uname() { case "$(uname -m)" in x86_64) echo amd64;; aarch64|arm64) echo arm64;; *) uname -m;; esac; }
