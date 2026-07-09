# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal macOS dotfiles managed with [chezmoi](https://www.chezmoi.io/). Files here are chezmoi **source state**, not the live dotfiles — chezmoi's naming conventions map them to targets in `$HOME`:

- `dot_config/zsh/dot_zshrc` → `~/.config/zsh/.zshrc`
- `private_secrets.zsh.tmpl` → `~/.config/zsh/secrets.zsh` (mode 600, rendered as a template)
- `run_onchange_before_install-packages.sh` → script that re-runs on `chezmoi apply` whenever its contents change

Note: the live chezmoi source directory is `~/.local/share/chezmoi`, which is a separate checkout of this same repo. Edits in this working copy do not reach `$HOME` until pushed and pulled via `chezmoi update`, or applied explicitly with `chezmoi apply --source <this dir>`.

## Common commands

Prefer chezmoi's own commands over hand-editing files in the source directory — they apply the naming conventions (`dot_`, `private_`, `.tmpl`) and keep source state and `$HOME` in sync.

**Inspect:**
```sh
chezmoi status                    # summary of pending changes (like git status)
chezmoi diff                      # preview what apply would change in $HOME
chezmoi verify                    # exit non-zero if $HOME differs from source state
chezmoi managed                   # list every path chezmoi tracks
chezmoi cat ~/.config/zsh/.zshrc  # show the rendered target without applying
chezmoi data                      # dump template variables
```

**Edit source state (don't edit files in the source dir by hand):**
```sh
chezmoi edit ~/.config/zsh/.zshrc         # open the *source* file for a target
chezmoi edit --apply ~/.config/zsh/.zshrc # edit, then apply in one step
chezmoi add ~/.config/foo/bar             # start managing a new dotfile
chezmoi re-add                            # pull external edits of already-managed files back into source
chezmoi chattr +template <target>         # convert a managed file into a template
```

**Apply / sync:**
```sh
chezmoi apply -v                  # apply source state to $HOME
chezmoi update -v                 # git pull in the source dir, then apply
chezmoi merge <target>            # 3-way merge when a target diverged from source
```

**Source repo & config:**
```sh
chezmoi cd                        # subshell in ~/.local/share/chezmoi
chezmoi git -- status             # run git inside the source dir without cd'ing
chezmoi edit-config               # edit chezmoi's own config
chezmoi execute-template < file.tmpl   # test-render a template (needs 1Password CLI for secrets)
```

There is no build/lint/test suite. After editing, run `chezmoi diff` (or `chezmoi verify`) to see the effect before `chezmoi apply`. Verify zsh changes by opening a new shell (or `zsh -i -c exit` for startup errors); verify WezTerm changes by saving `wezterm.lua` — WezTerm hot-reloads its config.

## Architecture

**ZSH lives under `ZDOTDIR=~/.config/zsh`, not `$HOME`.** `dot_zshenv` (the only zsh file in `$HOME`) bootstraps `ZDOTDIR` and manually sources `$ZDOTDIR/.zshenv`. Startup chain: `~/.zshenv` → `zsh/.zshenv` (XDG dirs, EDITOR) → `zsh/.zprofile` (Homebrew shellenv) → `zsh/.zshrc` (interactive setup).

**`.zshrc` plugin order is load-bearing.** The sequence must be: `compinit` → fzf-tab → (starship, fzf, zoxide) → zsh-autosuggestions → zsh-syntax-highlighting → zsh-history-substring-search. fzf-tab must load after compinit but before widget-wrapping plugins; history-substring-search must be last. Don't reorder when editing.

**No plugin manager.** Plugins come from Homebrew (sourced from `$BREW_PREFIX/share/...`), except fzf-tab, which chezmoi clones via `.chezmoiexternal.toml` into `~/.local/share/zsh/plugins/`.

**Packages are declared inline in `run_onchange_before_install-packages.sh`** as a heredoc Brewfile. To add a dependency, add a `brew "..."`/`cask "..."` line there — chezmoi hashes the script's contents, so the change itself triggers `brew bundle` on the next apply.

**Theming follows macOS light/dark appearance:**
- `.zshrc` reads `AppleInterfaceStyle` once at startup and sets `LS_COLORS` (via vivid: catppuccin-mocha dark / gruvbox-light-hard light) and `COLORFGBG` (which lets Claude Code's `auto` theme track the OS).
- `wezterm.lua` defines a theme table (Synthwave + a "minimal" light/dark family). Minimal themes auto-swap on OS appearance change via the `window-config-reloaded` event; the chosen theme persists in `~/.config/wezterm/.current-theme` (a state file, ignored via `.chezmoiignore` — never add it to source). Runtime picker: CTRL+SHIFT+T.
- `dot_config/wezterm/snippets/` holds opt-in config modules (panes/workspaces) enabled by a single `require` line in `wezterm.lua`.

**Secrets are chezmoi templates backed by 1Password.** `private_secrets.zsh.tmpl` uses `onepasswordRead` with an item UUID. Always edit the source template, never the rendered `~/.config/zsh/secrets.zsh` — `chezmoi edit ~/.config/zsh/secrets.zsh` opens the `.tmpl` for you. Rendering requires the 1Password CLI (`op`) to be signed in.
