#!/usr/bin/env bash
# Symlink tracked dotfiles from this repo into $HOME.
# - Backs up any existing real file to ~/.dotfiles-backup-<timestamp>/
# - .kiro is linked granularly (steering/, skills/, and individual settings
#   files) so Kiro runtime state (logs/, crew/, agents/) stays on local disk.
# - .ssh/config is selected by platform.
source "$(dirname "$0")/install/lib.sh"

REPO="$(cd "$(dirname "$0")" && pwd)"
SRC="$REPO/home"
BACKUP="$HOME/.dotfiles-backup-$(date +%Y%m%d%H%M%S)"
detect_platform

link() {
  local src="$1" dst="$2"
  mkdir -p "$(dirname "$dst")"
  # Already the correct symlink → nothing to do.
  if [ -L "$dst" ] && [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
    c_skip "linked: ${dst/#$HOME/~}"
    return
  fi
  # Back up an existing real file/dir (or wrong symlink).
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$BACKUP"
    mv "$dst" "$BACKUP/"
    c_warn "backed up ${dst/#$HOME/~} → ${BACKUP/#$HOME/~}/"
  fi
  ln -s "$src" "$dst"
  c_ok "linked: ${dst/#$HOME/~} → ${src/#$HOME/~}"
}

c_info "linking shell + git dotfiles"
for f in .zshrc .p10k.zsh .profile .bash_logout .z_profile .gitconfig; do
  link "$SRC/$f" "$HOME/$f"
done

c_info "linking .kiro config (granular — runtime state left untouched)"
link "$SRC/.kiro/steering" "$HOME/.kiro/steering"
link "$SRC/.kiro/skills"   "$HOME/.kiro/skills"
for f in cli.json mcp.json kiro_cli_theme.json; do
  link "$SRC/.kiro/settings/$f" "$HOME/.kiro/settings/$f"
done

c_info "linking .ssh/config for platform: $PLATFORM"
link "$SRC/.ssh/config.$PLATFORM" "$HOME/.ssh/config"
chmod 700 "$HOME/.ssh" 2>/dev/null || true

[ -d "$BACKUP" ] && c_warn "existing files were backed up to ${BACKUP/#$HOME/~}/"
c_ok "dotfiles linked"
