#!/usr/bin/env bash
# Bootstrap a new machine: developer tools + personalised dotfiles.
# Idempotent — safe to re-run to reconcile drift.
#
# Usage:
#   ./bootstrap.sh                 # auto-detect platform, run everything
#   ./bootstrap.sh --platform wsl  # force WSL
#   ./bootstrap.sh --platform linux
#   ./bootstrap.sh --only link     # run one stage: apt|languages|tools|shell|link
#   ./bootstrap.sh --skip apt      # skip a stage (repeatable)
#   ./bootstrap.sh --help

set -euo pipefail
REPO="$(cd "$(dirname "$0")" && pwd)"

# ---- Pinned versions (the ones that bite when they drift) ----
export TERRAFORM_VERSION="1.11.4"
export NODE_VERSION="v24.14.0"
export NVM_VERSION="v0.40.1"

export PLATFORM="${PLATFORM:-}"
ONLY=""; SKIP=()

while [ $# -gt 0 ]; do
  case "$1" in
    --platform) PLATFORM="$2"; shift 2;;
    --only)     ONLY="$2"; shift 2;;
    --skip)     SKIP+=("$2"); shift 2;;
    --help|-h)
      sed -n '1,10p' "$0" | sed 's/^# \{0,1\}//'; exit 0;;
    *) echo "unknown arg: $1" >&2; exit 2;;
  esac
done

if [ -n "$PLATFORM" ] && [ "$PLATFORM" != "wsl" ] && [ "$PLATFORM" != "linux" ]; then
  echo "error: --platform must be 'wsl' or 'linux'" >&2; exit 2
fi

source "$REPO/install/lib.sh"
detect_platform
c_info "platform: $PLATFORM"

run_stage() {
  local name="$1" cmd="$2"
  [ -n "$ONLY" ] && [ "$ONLY" != "$name" ] && return
  for s in "${SKIP[@]:-}"; do [ "$s" = "$name" ] && { c_skip "stage skipped: $name"; return; }; done
  c_info "stage: $name"
  PLATFORM="$PLATFORM" bash "$cmd"
}

run_stage apt       "$REPO/install/00-apt.sh"
run_stage languages "$REPO/install/10-languages.sh"
run_stage tools     "$REPO/install/20-tools.sh"
run_stage shell     "$REPO/install/30-shell.sh"

# link stage calls the top-level script directly (it is not under install/)
if [ -z "$ONLY" ] || [ "$ONLY" = "link" ]; then
  skip_link=false
  for s in "${SKIP[@]:-}"; do [ "$s" = "link" ] && skip_link=true; done
  if [ "$skip_link" = false ]; then
    c_info "stage: link"
    PLATFORM="$PLATFORM" bash "$REPO/link-dotfiles.sh"
  fi
fi

echo
c_ok "bootstrap complete"
c_info "next steps:"
echo "  1. Restart your shell (or: exec zsh) to load the new config."
echo "  2. Sign in to tools: glab auth login / gh auth login / aws-sso-util login."
echo "  3. SSH over 1Password: see README 'SSH via 1Password' for the one-time setup."
