# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal macOS dotfiles managed with [chezmoi](https://www.chezmoi.io/). Files here are chezmoi **source state**, not the live dotfiles — chezmoi's naming conventions map them to targets in `$HOME`.

**Source root is `home/`** (set by the `.chezmoiroot` file at the repo root), so all source paths below are under `home/`. The repo root holds only meta files (`README.md`, `ROADMAP.md`, `CLAUDE.md`) — they sit outside the source root, so chezmoi ignores them automatically (no `.chezmoiignore` entry needed).

- `home/dot_config/zsh/dot_zshrc` → `~/.config/zsh/.zshrc`
- `home/private_secrets.zsh.tmpl` → `~/.config/zsh/secrets.zsh` (mode 600, rendered as a template)
- `home/run_onchange_before_install-packages.sh` → script that re-runs on `chezmoi apply` whenever its contents change
- `home/.chezmoiremove` → declaratively deletes retired target paths on apply (see its header)

Note: the live chezmoi source directory is `~/.local/share/chezmoi` (with `chezmoi source-path` resolving to its `home/` subdir), a separate checkout of this same repo. Edits in this working copy do not reach `$HOME` until pushed and pulled via `chezmoi update`, or applied explicitly with `chezmoi apply --source <this dir>`.

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

**`.zshrc` is a loader; the real config lives in `dot_config/zsh/rc.d/NN-topic.zsh`.** `.zshrc` sources `rc.d/*.zsh(N)` in numeric-prefix order, so the prefix encodes load order. To add config, drop a new `NN-topic.zsh` in `rc.d/` with an `NN` that places it correctly — no need to touch `.zshrc`.

**The load order across those files is load-bearing.** The sequence must be: `20-homebrew` (`$BREW_PREFIX`) → `30-appearance` (`$LS_COLORS`) → `40-completion` (compinit → fzf-tab) → `50-tools` (starship, fzf, zoxide, mise, then zsh-autosuggestions → zsh-syntax-highlighting → zsh-history-substring-search LAST) → `55-atuin` → `60-keybindings`. fzf-tab must load after compinit but before widget-wrapping plugins; history-substring-search must be sourced last among the plugins. atuin (`55`) owns Ctrl-R (overrides fzf's) and is initialized with `--disable-up-arrow` so Up/Down stay on zsh-history-substring-search. Don't reorder the prefixes when editing.

**No plugin manager.** Plugins come from Homebrew (sourced from `$BREW_PREFIX/share/...`), except fzf-tab, which chezmoi clones via `.chezmoiexternal.toml` into `~/.local/share/zsh/plugins/`.

**Packages are declared inline in `run_onchange_before_install-packages.sh`** as a heredoc Brewfile. To add a dependency, add a `brew "..."`/`cask "..."` line there — chezmoi hashes the script's contents, so the change itself triggers `brew bundle` on the next apply.

**Theming follows macOS light/dark appearance:**
- `.zshrc` reads `AppleInterfaceStyle` once at startup and sets `LS_COLORS` (via vivid: catppuccin-mocha dark / gruvbox-light-hard light) and `COLORFGBG` (which lets Claude Code's `auto` theme track the OS).
- `wezterm.lua` defines a theme table (Synthwave + a "minimal" light/dark family). Minimal themes auto-swap on OS appearance change via the `window-config-reloaded` event; the chosen theme persists in `~/.config/wezterm/.current-theme` (a state file, ignored via `.chezmoiignore` — never add it to source). Runtime picker: CTRL+SHIFT+T.
- `dot_config/wezterm/snippets/` holds opt-in config modules (panes/workspaces) enabled by a single `require` line in `wezterm.lua`.

**Secrets are chezmoi templates backed by 1Password.** `private_secrets.zsh.tmpl` uses `onepasswordRead` with an item UUID. Always edit the source template, never the rendered `~/.config/zsh/secrets.zsh` — `chezmoi edit ~/.config/zsh/secrets.zsh` opens the `.tmpl` for you. Rendering requires the 1Password CLI (`op`) to be signed in.

**The repo is a PUBLIC GitHub repo, so anything reconnaissance-sensitive is age-encrypted, not committed in the clear.** `~/.ssh/config` (internal hostnames, IPs, users) lives in source as `private_dot_ssh/encrypted_private_config.age`. Encryption config is in `.chezmoi.toml.tmpl` (`encryption = "age"` + a public `recipient` — safe to commit). The **private** age identity lives only at `~/.config/chezmoi/key.txt` and in 1Password (document `chezmoi-age-key`, Private vault); it is never committed. To edit the ssh config, use `chezmoi edit ~/.ssh/config` (chezmoi decrypts, you edit plaintext, it re-encrypts). To manage another sensitive file the same way: `chezmoi add --encrypt <path>`.

**New-machine bootstrap.** The one-liner in `README.md` runs `install.sh` (repo
root, outside the source root), which sequences Xcode CLT → Homebrew → chezmoi +
age + 1Password (CLI + app) → `op` sign-in → `chezmoi init --apply sadorlovsky`.

The age key no longer needs to be provisioned by hand: **`run_before_00-fetch-age-key.sh.tmpl`**
fetches it from 1Password (`chezmoi-age-key`, Private vault) on the first apply,
before any `encrypted_` file is decrypted — chezmoi guarantees `run_before_`
scripts run first. It no-ops once `~/.config/chezmoi/key.txt` exists (every
subsequent `apply`/`update`), and exits with actionable guidance if the key is
missing and `op` is unavailable/signed-out. Manual fallback if ever needed:
```sh
op document get chezmoi-age-key --vault Private > ~/.config/chezmoi/key.txt
chmod 600 ~/.config/chezmoi/key.txt
```
