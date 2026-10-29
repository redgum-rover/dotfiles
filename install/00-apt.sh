#!/usr/bin/env bash
# apt repos + packages. Idempotent: re-running reconciles, never clobbers.
source "$(dirname "$0")/lib.sh"

c_info "apt: base packages"
sudo apt-get update -qq
sudo apt-get install -y -qq \
  curl wget git gnupg ca-certificates lsb-release software-properties-common \
  build-essential unzip jq sqlite3 socat zsh vim >/dev/null
c_ok "base packages installed"

# --- HashiCorp (terraform, pinned) ---
if ! have terraform; then
  c_info "apt: HashiCorp repo + terraform"
  wget -qO- https://apt.releases.hashicorp.com/gpg \
    | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
  echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
    | sudo tee /etc/apt/sources.list.d/hashicorp.list >/dev/null
  sudo apt-get update -qq
  sudo apt-get install -y -qq "terraform=${TERRAFORM_VERSION}-1" >/dev/null \
    || sudo apt-get install -y -qq terraform >/dev/null
  c_ok "terraform installed"
else
  c_skip "terraform present ($(terraform version | head -1))"
fi

# --- GitHub CLI ---
if ! have gh; then
  c_info "apt: GitHub CLI repo + gh"
  wget -qO- https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg >/dev/null 2>&1
  sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
  echo "deb [arch=$(arch_deb) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] \
https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
  sudo apt-get update -qq && sudo apt-get install -y -qq gh >/dev/null
  c_ok "gh installed"
else
  c_skip "gh present"
fi

# --- GitLab CLI (glab) ---
if ! have glab; then
  c_info "install glab"
  GLAB_VER="$(wget -qO- https://gitlab.com/api/v4/projects/gitlab-org%2Fcli/releases/permalink/latest \
    | jq -r .tag_name | sed 's/^v//')"
  tmp="$(mktemp -d)"
  wget -qO "$tmp/glab.deb" \
    "https://gitlab.com/gitlab-org/cli/-/releases/v${GLAB_VER}/downloads/glab_${GLAB_VER}_linux_$(arch_deb).deb"
  sudo dpkg -i "$tmp/glab.deb" >/dev/null && rm -rf "$tmp"
  c_ok "glab installed"
else
  c_skip "glab present"
fi

# --- JFrog CLI (jf) ---
if ! have jf; then
  c_info "apt: JFrog CLI repo + jf"
  wget -qO - https://releases.jfrog.io/artifactory/jfrog-gpg-public/jfrog_public_gpg.key \
    | sudo gpg --dearmor -o /usr/share/keyrings/jfrog.gpg
  echo "deb [signed-by=/usr/share/keyrings/jfrog.gpg] \
https://releases.jfrog.io/artifactory/jfrog-debs xenial contrib" \
    | sudo tee /etc/apt/sources.list.d/jfrog.list >/dev/null
  sudo apt-get update -qq && sudo apt-get install -y -qq jfrog-cli-v2-jf >/dev/null
  c_ok "jf installed"
else
  c_skip "jf present"
fi

# --- Docker Engine ---
if ! have docker; then
  c_info "apt: Docker repo + engine"
  sudo install -m 0755 -d /etc/apt/keyrings
  wget -qO- https://download.docker.com/linux/ubuntu/gpg \
    | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
  sudo chmod a+r /etc/apt/keyrings/docker.gpg
  echo "deb [arch=$(arch_deb) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
    | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get update -qq
  sudo apt-get install -y -qq docker-ce docker-ce-cli containerd.io \
    docker-buildx-plugin docker-compose-plugin >/dev/null
  sudo usermod -aG docker "$USER" || true
  c_ok "docker installed (log out/in for group membership)"
else
  c_skip "docker present"
fi
