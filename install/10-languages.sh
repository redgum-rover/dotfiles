#!/usr/bin/env bash
# Languages: nvm + node (pinned), pipx. Idempotent.
source "$(dirname "$0")/lib.sh"

export NVM_DIR="$HOME/.nvm"

# --- nvm ---
if [ ! -s "$NVM_DIR/nvm.sh" ]; then
  c_info "install nvm ${NVM_VERSION}"
  PROFILE=/dev/null bash -c \
    "curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/${NVM_VERSION}/install.sh | bash" >/dev/null
  c_ok "nvm installed"
else
  c_skip "nvm present"
fi

# shellcheck disable=SC1091
. "$NVM_DIR/nvm.sh"

# --- node (pinned) ---
if ! nvm ls "$NODE_VERSION" >/dev/null 2>&1; then
  c_info "install node ${NODE_VERSION}"
  nvm install "$NODE_VERSION" >/dev/null
  nvm alias default "$NODE_VERSION" >/dev/null
  c_ok "node ${NODE_VERSION} installed + set default"
else
  c_skip "node ${NODE_VERSION} present"
fi

# --- pipx ---
if ! have pipx; then
  c_info "install pipx"
  sudo apt-get install -y -qq pipx >/dev/null
  pipx ensurepath >/dev/null 2>&1 || true
  c_ok "pipx installed"
else
  c_skip "pipx present"
fi

# --- aws-sso-util (via pipx) ---
if ! have aws-sso-util; then
  c_info "install aws-sso-util"
  pipx install aws-sso-util >/dev/null
  c_ok "aws-sso-util installed"
else
  c_skip "aws-sso-util present"
fi
