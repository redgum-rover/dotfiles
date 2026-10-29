#!/usr/bin/env bash
# Standalone CLIs into ~/.local/bin and /usr/local/bin. Idempotent.
source "$(dirname "$0")/lib.sh"

mkdir -p "$HOME/.local/bin"

# --- AWS CLI v2 ---
if ! have aws; then
  c_info "install AWS CLI v2"
  tmp="$(mktemp -d)"
  case "$(arch_uname)" in
    amd64) awspkg="awscli-exe-linux-x86_64.zip";;
    arm64) awspkg="awscli-exe-linux-aarch64.zip";;
  esac
  wget -qO "$tmp/aws.zip" "https://awscli.amazonaws.com/${awspkg}"
  (cd "$tmp" && unzip -q aws.zip && ./aws/install --bin-dir "$HOME/.local/bin" \
     --install-dir "$HOME/.local/aws-cli" --update)
  rm -rf "$tmp"
  c_ok "aws cli installed ($(aws --version 2>&1))"
else
  c_skip "aws cli present"
fi

# --- kubectl (pinned minor via stable channel) ---
if ! have kubectl; then
  c_info "install kubectl"
  ver="$(wget -qO- https://dl.k8s.io/release/stable.txt)"
  wget -qO "$HOME/.local/bin/kubectl" \
    "https://dl.k8s.io/release/${ver}/bin/linux/$(arch_uname)/kubectl"
  chmod +x "$HOME/.local/bin/kubectl"
  c_ok "kubectl installed ($ver)"
else
  c_skip "kubectl present"
fi

# --- helm ---
if ! have helm; then
  c_info "install helm"
  curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 \
    | HELM_INSTALL_DIR="$HOME/.local/bin" USE_SUDO=false bash >/dev/null
  c_ok "helm installed"
else
  c_skip "helm present"
fi

# --- kiro-cli ---
if ! have kiro-cli; then
  c_info "install kiro-cli"
  curl -fsSL https://desktop-release.kiro.dev/latest/kiro-cli-install.sh | bash >/dev/null 2>&1 \
    || c_warn "kiro-cli installer failed — install manually (see README)"
  have kiro-cli && c_ok "kiro-cli installed"
else
  c_skip "kiro-cli present"
fi

# --- pulumi ---
if ! have pulumi; then
  c_info "install pulumi"
  curl -fsSL https://get.pulumi.com | sh >/dev/null 2>&1
  c_ok "pulumi installed to ~/.pulumi/bin"
else
  c_skip "pulumi present"
fi

# --- 1Password CLI (op) ---
if ! have op; then
  c_info "install 1Password CLI"
  OP_VER="$(wget -qO- https://app-updates.agilebits.com/product_history/CLI2 \
    | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1 | sed 's/^v//')"
  tmp="$(mktemp -d)"
  if wget -qO "$tmp/op.zip" \
      "https://cache.agilebits.com/dist/1P/op2/pkg/v${OP_VER}/op_linux_$(arch_uname)_v${OP_VER}.zip"; then
    (cd "$tmp" && unzip -q op.zip && install -m 0755 op "$HOME/.local/bin/op")
    c_ok "op installed (v${OP_VER})"
  else
    c_warn "op download failed — install the 1Password CLI manually (see README)"
  fi
  rm -rf "$tmp"
else
  c_skip "op present"
fi

# --- npiperelay (WSL only, for the 1Password SSH agent bridge) ---
detect_platform
if [ "$PLATFORM" = "wsl" ] && ! have npiperelay.exe; then
  c_warn "WSL: npiperelay.exe not found. The 1Password SSH agent bridge needs it."
  c_warn "     One-time Windows-side setup is documented in the README."
fi
