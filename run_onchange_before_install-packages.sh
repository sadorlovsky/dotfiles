#!/bin/bash
# Install the Homebrew packages these dotfiles depend on.
# chezmoi run_onchange_ script: re-runs automatically whenever the package list
# below changes (the list is part of this file's contents, which chezmoi hashes).
set -eu

if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found — install it first (https://brew.sh), then run 'chezmoi apply'." >&2
    exit 0
fi

# zsh-ai ships from a third-party tap. Homebrew 6+ refuses to load formulae
# from untrusted taps when HOMEBREW_REQUIRE_TAP_TRUST is set, so tap and trust
# it explicitly before the bundle runs.
brew tap matheusml/zsh-ai
brew trust --tap matheusml/zsh-ai

brew bundle --file=/dev/stdin <<'BREWFILE'
# Shell tools
brew "starship"
brew "zoxide"
brew "fzf"
brew "fd"
brew "eza"
brew "bat"
brew "vivid"
brew "jq"
brew "chezmoi"
brew "mise"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
brew "zsh-history-substring-search"

# zsh-ai — natural-language command generation (from matheusml/zsh-ai tap,
# tapped and trusted above)
brew "matheusml/zsh-ai/zsh-ai"

# Terminal
cask "wezterm@nightly"

# Fonts — Fairfax Hax (bundled in the Fairfax family) is the WezTerm UI font
cask "font-fairfax"
BREWFILE
