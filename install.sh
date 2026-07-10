#!/bin/sh
# Bootstrap these dotfiles on a fresh macOS machine, end to end:
#
#   sh -c "$(curl -fsLS https://dotfiles.orlovsky.dev)"
#
# (dotfiles.orlovsky.dev is a Cloudflare 302 → this file's raw GitHub URL.)
#
# It brings the machine from "nothing installed" to a fully-applied config:
#   Xcode CLT → Homebrew → chezmoi + age + 1Password CLI/app → op sign-in
#   → chezmoi init --apply (which fetches the age key from 1Password and installs
#   every Homebrew package via the run_ scripts in the repo).
#
# Safe to re-run: every step is idempotent and skips work already done. Lives at
# the repo root, outside the chezmoi source root (home/), so chezmoi ignores it.
set -eu

GITHUB_USER="sadorlovsky"

info() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

# --- 0. Sanity: this bootstrap is macOS-only ---------------------------------
[ "$(uname -s)" = "Darwin" ] || die \
    "These dotfiles target macOS. On Linux, install chezmoi yourself and run:
       chezmoi init --apply $GITHUB_USER"

# --- 1. Xcode Command Line Tools (git, cc — Homebrew needs them) --------------
if ! xcode-select -p >/dev/null 2>&1; then
    info "Installing Xcode Command Line Tools…"
    xcode-select --install >/dev/null 2>&1 || true
    die "Finish the Command Line Tools install in the popup, then re-run this script."
fi

# --- 2. Homebrew -------------------------------------------------------------
if ! command -v brew >/dev/null 2>&1; then
    info "Installing Homebrew…"
    NONINTERACTIVE=1 /bin/bash -c \
        "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
# Load brew into THIS shell (Apple Silicon vs Intel prefix).
if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi
command -v brew >/dev/null 2>&1 || die "Homebrew installed but 'brew' is not on PATH."

# --- 3. Bootstrap tools needed before the first apply ------------------------
# chezmoi drives everything; age + 1Password CLI are needed to fetch and use the
# encryption key. The rest of the Brewfile is installed by chezmoi during apply.
info "Installing bootstrap tools (chezmoi, age, 1Password CLI)…"
brew install chezmoi age 1password-cli
info "Installing the 1Password app…"
brew install --cask 1password || warn "Could not install the 1Password app cask (already present?)."

# --- 4. 1Password sign-in (needed to fetch the age key + render secrets) ------
if ! op whoami >/dev/null 2>&1; then
    cat >&2 <<'EOF'

  1Password CLI is not signed in yet. To continue:
    1. Open the 1Password app → Settings → Developer →
       enable "Integrate with 1Password CLI".
    2. Unlock the app (Touch ID), or run:  eval "$(op signin)"
  Then re-run this script.

EOF
    die "Sign in to 1Password, then re-run."
fi

# --- 5. Hand off to chezmoi --------------------------------------------------
# init --apply clones the repo and applies it. A run_before_ script fetches the
# age key from 1Password before any encrypted file is read; a run_onchange_
# script runs `brew bundle` to install the full package list.
info "Initializing dotfiles with chezmoi…"
exec chezmoi init --apply "$GITHUB_USER"
