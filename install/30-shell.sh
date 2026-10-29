#!/usr/bin/env bash
# zsh framework: oh-my-zsh + powerlevel10k, set zsh as default shell. Idempotent.
source "$(dirname "$0")/lib.sh"

# --- oh-my-zsh (unattended; don't let it chsh or run zsh) ---
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  c_info "install oh-my-zsh"
  RUNZSH=no CHSH=no KEEP_ZSHRC=yes \
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" >/dev/null
  c_ok "oh-my-zsh installed"
else
  c_skip "oh-my-zsh present"
fi

# --- powerlevel10k theme ---
P10K_DIR="$HOME/.oh-my-zsh/custom/themes/powerlevel10k"
if [ ! -d "$P10K_DIR" ]; then
  c_info "install powerlevel10k"
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_DIR" >/dev/null 2>&1
  c_ok "powerlevel10k installed"
else
  c_skip "powerlevel10k present"
fi

# --- make zsh the default login shell ---
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]; then
  c_info "set zsh as default shell"
  sudo chsh -s "$(command -v zsh)" "$USER" \
    && c_ok "default shell set to zsh (effective next login)" \
    || c_warn "could not chsh — run: chsh -s $(command -v zsh)"
else
  c_skip "zsh already default shell"
fi
