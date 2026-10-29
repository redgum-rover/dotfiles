# dotfiles

Bootstrap a new machine with my developer tools and shell personalisation.
Targets **Ubuntu/WSL2** and **native Ubuntu Linux** from one repo.

> ⚠️ **Private repo only.** The `home/.kiro/steering/` docs contain
> BHP-internal context (org structure, account IDs, incident detail). Never
> push this to a public remote.

## Quick start (fresh machine)

```bash
git clone git@gitlab.com:<you>/dotfiles.git ~/dotfiles
cd ~/dotfiles
./bootstrap.sh                 # auto-detects WSL vs native Linux
exec zsh                       # load the new shell config
```

Then sign in to tools (interactive, not scripted):

```bash
glab auth login
gh auth login
aws-sso-util login -u https://bhp.awsapps.com/start
```

## What it does

| Stage | Installs |
|-------|----------|
| `apt` | curl, git, jq, sqlite3, socat, zsh, vim, build tools; terraform (pinned), gh, glab, jf, docker |
| `languages` | nvm + node (pinned), pipx, aws-sso-util |
| `tools` | aws cli v2, kubectl, helm, kiro-cli, pulumi, 1Password CLI (`op`) |
| `shell` | oh-my-zsh, powerlevel10k, set zsh as default shell |
| `link` | symlink tracked dotfiles into `$HOME` (backs up existing files) |

Pinned versions live at the top of `bootstrap.sh` (`TERRAFORM_VERSION`,
`NODE_VERSION`, `NVM_VERSION`). Everything else tracks latest.

### Flags

```bash
./bootstrap.sh --platform wsl|linux   # override auto-detection
./bootstrap.sh --only link            # run one stage (apt|languages|tools|shell|link)
./bootstrap.sh --skip apt             # skip a stage (repeatable)
```

The script is **idempotent** — re-run it any time to reconcile a machine.
Re-running `link` only fixes drift; it never double-backs-up.

## Dotfiles model

Tracked files live under `home/` and are **symlinked** into `$HOME`, so editing
`~/.zshrc` edits the repo file directly — `git diff` shows it immediately.

`.kiro` is linked **granularly** (`steering/`, `skills/`, and the three
`settings/*.json` config files) so Kiro's runtime state (`logs/`, `crew/`,
`agents/`, lockfiles) stays on local disk and never enters git.

Existing real files are moved to `~/.dotfiles-backup-<timestamp>/` before a
symlink is created.

## Secrets

This repo tracks **config only**. `.gitignore` denies credentials and machine
state by habit: `.aws/`, `.ssh/id_*`, `.gnupg/`, `.docker/config.json`,
`.jfrog/`, `.kube/config`, `.claude.json`, `*.env`, all `*_history`, and Kiro
runtime state. SSH private keys live in **1Password**, never on disk — see below.

## SSH via 1Password

Git pushes over SSH, authenticated by the **1Password SSH agent**. The private
key never touches disk. The tracked `~/.ssh/config` points `IdentityAgent` at
the agent socket (platform-specific variant selected by the `link` stage).

**One-time manual setup** (GUI / Windows-side — a Linux script can't do these):

**Native Linux:**
1. Install the 1Password desktop app and sign in.
2. Settings → Developer → **Use the SSH agent**.
3. The agent serves `~/.1password/agent.sock` — already referenced by `.ssh/config`.

**WSL2:** the agent runs in the **Windows** 1Password app; WSL reaches it via a relay.
1. In Windows 1Password: Settings → Developer → **Use the SSH agent**.
2. Install [`npiperelay.exe`](https://github.com/jstarks/npiperelay) on Windows
   and put it on the Windows `PATH` (so `npiperelay.exe` resolves from WSL).
3. `socat` is installed by the `apt` stage. The `.zshrc` relay snippet then
   bridges the Windows agent to `~/.1password/agent.sock` in WSL automatically
   on shell start.

**Register your public key** once in GitLab/GitHub (same key works everywhere):

```bash
op item get "GitLab SSH Key" --fields "public key"   # or copy from the 1Password UI
# paste into GitLab → Preferences → SSH Keys
ssh -T git@gitlab.com    # verify
```

## Layout

```
bootstrap.sh        entry point, --platform / --only / --skip
install/
  lib.sh            shared helpers + platform detection
  00-apt.sh         apt repos & packages
  10-languages.sh   nvm/node, pipx, aws-sso-util
  20-tools.sh       standalone CLIs + op
  30-shell.sh       oh-my-zsh, p10k, default shell
link-dotfiles.sh    symlink home/* into $HOME (granular .kiro, platform .ssh)
home/               the tracked dotfiles (source of truth)
```
