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
brew "atuin"              # SQLite-backed shell history + fuzzy Ctrl-R search
brew "fzf"
brew "fd"
brew "eza"
brew "bat"
brew "chafa"             # terminal image previews (fzf CTRL-T on images)
brew "hexyl"             # hex preview of binaries (fzf CTRL-T on non-text)
brew "git-delta"          # syntax-highlighting pager for git diffs (theme via $BAT_THEME)
brew "vivid"
brew "jq"
brew "helix"              # $EDITOR (hx)
brew "chezmoi"
brew "age"                # decrypts encrypted_ source files (e.g. ~/.ssh/config)
brew "mise"
brew "zsh-autosuggestions"
brew "zsh-syntax-highlighting"
brew "zsh-history-substring-search"

# zsh-ai — natural-language command generation (from matheusml/zsh-ai tap,
# tapped and trusted above)
brew "matheusml/zsh-ai/zsh-ai"

# Terminal
cask "wezterm@nightly"

# Secrets — 1Password app + CLI back the age key and secrets.zsh templates
cask "1password"
cask "1password-cli"

# Fonts — Fairfax Hax (bundled in the Fairfax family) is the WezTerm UI font;
# JetBrains Mono is the WezTerm text font.
cask "font-fairfax"
cask "font-jetbrains-mono"
BREWFILE
