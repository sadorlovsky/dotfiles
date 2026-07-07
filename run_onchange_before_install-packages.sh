#!/bin/bash
# Install the Homebrew packages these dotfiles depend on.
# chezmoi run_onchange_ script: re-runs automatically whenever the package list
# below changes (the list is part of this file's contents, which chezmoi hashes).
set -eu

if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found — install it first (https://brew.sh), then run 'chezmoi apply'." >&2
    exit 0
fi

brew bundle --file=/dev/stdin <<'BREWFILE'
# Shell tools
brew "starship"
brew "zoxide"
brew "fzf"
brew "fd"
brew "eza"
brew "bat"
brew "vivid"
brew "chezmoi"
brew "mise"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
brew "zsh-history-substring-search"

# Terminal
cask "wezterm@nightly"
BREWFILE
