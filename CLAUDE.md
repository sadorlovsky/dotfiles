# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal macOS dotfiles managed with [chezmoi](https://www.chezmoi.io/). Files here are chezmoi **source state**, not the live dotfiles — chezmoi's naming conventions map them to targets in `$HOME`:

- `dot_config/zsh/dot_zshrc` → `~/.config/zsh/.zshrc`
- `private_secrets.zsh.tmpl` → `~/.config/zsh/secrets.zsh` (mode 600, rendered as a template)
- `run_onchange_before_install-packages.sh` → script that re-runs on `chezmoi apply` whenever its contents change

Note: the live chezmoi source directory is `~/.local/share/chezmoi`, which is a separate checkout of this same repo. Edits in this working copy do not reach `$HOME` until pushed and pulled via `chezmoi update`, or applied explicitly with `chezmoi apply --source <this dir>`.

## Common commands

```sh
chezmoi diff                      # preview what apply would change in $HOME
chezmoi apply -v                  # apply source state to $HOME
chezmoi update -v                 # pull latest from git and apply
chezmoi add <file>                # stage a locally-changed dotfile back into source state
chezmoi execute-template < file.tmpl   # test-render a template (needs 1Password CLI for secrets)
```

There is no build/lint/test suite. Verify zsh changes by opening a new shell (or `zsh -i -c exit` for startup errors); verify WezTerm changes by saving `wezterm.lua` — WezTerm hot-reloads its config.

## Architecture

**ZSH lives under `ZDOTDIR=~/.config/zsh`, not `$HOME`.** `dot_zshenv` (the only zsh file in `$HOME`) bootstraps `ZDOTDIR` and manually sources `$ZDOTDIR/.zshenv`. Startup chain: `~/.zshenv` → `zsh/.zshenv` (XDG dirs, EDITOR) → `zsh/.zprofile` (Homebrew shellenv) → `zsh/.zshrc` (interactive setup).

**`.zshrc` plugin order is load-bearing.** The sequence must be: `compinit` → fzf-tab → (starship, fzf, zoxide) → zsh-autosuggestions → zsh-syntax-highlighting → zsh-history-substring-search. fzf-tab must load after compinit but before widget-wrapping plugins; history-substring-search must be last. Don't reorder when editing.

**No plugin manager.** Plugins come from Homebrew (sourced from `$BREW_PREFIX/share/...`), except fzf-tab, which chezmoi clones via `.chezmoiexternal.toml` into `~/.local/share/zsh/plugins/`.

**Packages are declared inline in `run_onchange_before_install-packages.sh`** as a heredoc Brewfile. To add a dependency, add a `brew "..."`/`cask "..."` line there — chezmoi hashes the script's contents, so the change itself triggers `brew bundle` on the next apply.

**Theming follows macOS light/dark appearance:**
- `.zshrc` reads `AppleInterfaceStyle` once at startup and sets `LS_COLORS` (via vivid: catppuccin-mocha dark / gruvbox-light-hard light) and `COLORFGBG` (which lets Claude Code's `auto` theme track the OS).
- `wezterm.lua` defines a theme table (Synthwave + a "minimal" light/dark family). Minimal themes auto-swap on OS appearance change via the `window-config-reloaded` event; the chosen theme persists in `~/.config/wezterm/.current-theme` (a state file, ignored via `.chezmoiignore` — never add it to source). Runtime picker: CTRL+SHIFT+T.
- `dot_config/wezterm/snippets/` holds opt-in config modules (panes/workspaces) enabled by a single `require` line in `wezterm.lua`.

**Secrets are chezmoi templates backed by 1Password.** `private_secrets.zsh.tmpl` uses `onepasswordRead` with an item UUID. Always edit the `.tmpl` in source state, never the rendered `~/.config/zsh/secrets.zsh`. Rendering requires the 1Password CLI (`op`) to be signed in.
