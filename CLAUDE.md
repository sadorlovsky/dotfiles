# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Personal macOS dotfiles managed with [chezmoi](https://www.chezmoi.io/). Files here are chezmoi **source state**, not the live dotfiles — chezmoi's naming conventions map them to targets in `$HOME`.

**Source root is `home/`** (set by the `.chezmoiroot` file at the repo root), so all source paths below are under `home/`. The repo root holds only meta files (`README.md`, `ROADMAP.md`, `CLAUDE.md`) — they sit outside the source root, so chezmoi ignores them automatically (no `.chezmoiignore` entry needed).

- `home/dot_config/zsh/dot_zshrc` → `~/.config/zsh/.zshrc`
- `home/private_secrets.zsh.tmpl` → `~/.config/zsh/secrets.zsh` (mode 600, rendered as a template)
- `home/run_onchange_before_install-packages.sh` → script that re-runs on `chezmoi apply` whenever its contents change
- `home/dot_claude/modify_settings.json` → `~/.claude/settings.json`, *patched* rather than written: chezmoi runs the file as a script with the current target on stdin and replaces the target with its stdout
- `home/dot_claude/skills/symlink_mastodon-upgrade` → `~/.claude/skills/mastodon-upgrade`, a **symlink** whose target is that file's contents
- `home/private_dot_ssh/encrypted_private_config.age` → `~/.ssh/config`, decrypted on apply with the age identity
- `home/private_dot_ssh/private_control/empty_dot_keep` → `~/.ssh/control/.keep`, an empty file whose only job is to make git carry the directory ssh multiplexes into
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

There is no build/lint/test suite. After editing, run `chezmoi diff` (or `chezmoi verify`) to see the effect before `chezmoi apply`. Verify zsh changes by opening a new shell (or `zsh -i -c exit` for startup errors); verify WezTerm changes by saving `wezterm.lua` — WezTerm hot-reloads its config. Nothing calls `wezterm.add_to_config_reload_watch_list`, so editing a file under `modules/` does not trigger that reload on its own: re-save `wezterm.lua` afterwards.

## Architecture

**ZSH lives under `ZDOTDIR=~/.config/zsh`, not `$HOME`.** `dot_zshenv` (the only zsh file in `$HOME`) bootstraps `ZDOTDIR` and manually sources `$ZDOTDIR/.zshenv`. Startup chain: `~/.zshenv` → `zsh/.zshenv` (XDG dirs, EDITOR) → `zsh/.zprofile` (Homebrew shellenv) → `zsh/.zshrc` (interactive setup).

**`.zshrc` is a loader; the real config lives in `dot_config/zsh/rc.d/NN-topic.zsh`.** `.zshrc` sources `rc.d/*.zsh(N)` in numeric-prefix order, so the prefix encodes load order. To add config, drop a new `NN-topic.zsh` in `rc.d/` with an `NN` that places it correctly — no need to touch `.zshrc`.

**The load order across those files is load-bearing.** The sequence must be: `20-homebrew` (`$BREW_PREFIX`) → `30-appearance` (`$LS_COLORS`) → `40-completion` (compinit → fzf-tab) → `50-tools` (starship, fzf, zoxide, mise, then zsh-autosuggestions → zsh-syntax-highlighting → zsh-history-substring-search LAST) → `55-atuin` → `60-keybindings`. fzf-tab must load after compinit but before widget-wrapping plugins; history-substring-search must be sourced last among the plugins. atuin (`55`) owns Ctrl-R (overrides fzf's) and is initialized with `--disable-up-arrow` so Up/Down stay on zsh-history-substring-search. Don't reorder the prefixes when editing.

**No plugin manager.** Plugins come from Homebrew (sourced from `$BREW_PREFIX/share/...`), except fzf-tab, which chezmoi clones via `.chezmoiexternal.toml` into `~/.local/share/zsh/plugins/`.

**Two externals, both git repos** (`.chezmoiexternal.toml`): fzf-tab, and the personal Claude Code skills repo cloned to `~/.local/share/claude-skills`. The skills repo is private and pulled over SSH, so the *first* apply on a new machine fails that clone (the ssh config lands in the same run) and the second succeeds. Both refresh weekly; `chezmoi apply --refresh-externals` pulls now.

**Packages are declared inline in `run_onchange_before_install-packages.sh`** as a heredoc Brewfile. To add a dependency, add a `brew "..."`/`cask "..."` line there — chezmoi hashes the script's contents, so the change itself triggers `brew bundle` on the next apply.

**Theming follows macOS light/dark appearance:**
- `rc.d/30-appearance.zsh` reads `AppleInterfaceStyle` once at startup and sets `LS_COLORS` (via vivid: catppuccin-mocha dark / gruvbox-light-hard light), `BAT_THEME` (which bat *and* git-delta follow — delta deliberately sets no `syntax-theme`), and `COLORFGBG` (which lets Claude Code's `auto` theme track the OS). One read at startup, so a light/dark flip needs a new shell.
- Helix can't follow the OS at runtime, so `dot_config/helix/config.toml` pins `catppuccin_mocha_transparent` — a local override in `helix/themes/` that clears `ui.background` so the WezTerm background image shows through. See ROADMAP for the (still unsolved) auto-switch.
- `wezterm.lua` is a thin entry point: every concern is a module under `dot_config/wezterm/modules/` (`general`, `links`, `mouse`, `keys`, `ssh`, `theme`; `tabbar` is wired from `theme`), each exporting `M.apply(config)`. Add a concern as a new module + one `require(...).apply(config)` line.
- `modules/theme.lua` holds the theme table (Synthwave + a "minimal" light/dark family). Minimal themes auto-swap on OS appearance change via the `window-config-reloaded` event; the chosen theme persists in `~/.config/wezterm/.current-theme` (a state file, ignored via `.chezmoiignore` — never add it to source). Runtime picker: CTRL+SHIFT+T, which lives in `theme.lua` (it needs `apply_theme`) while all other keys live in `keys.lua`.
- `modules/ssh.lua` generates an `ssh_domain` per host in `~/.ssh/config` at config-load time, so it depends on the decrypted ssh config being in place.
- `dot_config/wezterm/snippets/` holds opt-in config modules (panes/workspaces), same `M.apply(config)` contract, enabled by a single `require` line in `wezterm.lua`.

**Secrets are chezmoi templates backed by 1Password.** `private_secrets.zsh.tmpl` uses `onepasswordRead` with an item UUID. Always edit the source template, never the rendered `~/.config/zsh/secrets.zsh` — `chezmoi edit ~/.config/zsh/secrets.zsh` opens the `.tmpl` for you. Rendering goes through the 1Password **desktop app** (CLI↔app integration + biometrics), so the app must be running and unlocked.

**`.chezmoiignore` is a template, and its 1Password guard is deliberate.** It skips `secrets.zsh` when the 1Password *process* isn't running, so `onepasswordRead` can't hang or abort an apply. Read the comment in the file before touching it: gating on `op whoami` (or `op account list`) instead is measurably wrong — `onepasswordRead` creates no CLI session, so `whoami` reports "not signed in" on a machine where reads work fine, and the guard would skip `secrets.zsh` for no reason. The one case it can't catch is *app running but locked*; unlock before a full apply.

**Claude Code's own config is managed here, under `dot_claude/`.** Four distinct pieces:
- `dot_claude/CLAUDE.md` → `~/.claude/CLAUDE.md` — personal *global* instructions for every project (BSD-not-GNU userland, Homebrew as the single install source, working style). Not to be confused with this file, which is guidance for this repo only.
- `dot_claude/modify_settings.json` → `~/.claude/settings.json` — shared ownership: Claude Code rewrites that file at runtime (plugins, model, `/config`), so a `modify_` script pipes the current contents through `jq` and enforces only the keys we claim (today: `statusLine`). Add keys there, never manage the file whole.
- `dot_claude/statusline-command.sh` — the statusline: cwd, git branch, model, a context-usage bar, 5h/7d rate-limit percentages, and a billing segment. It derives billing from env (`CLAUDE_CODE_USE_BEDROCK` / `_VERTEX`, `ANTHROPIC_API_KEY`) plus the plan and extra-usage flags read out of `~/.claude.json`, mirroring Claude Code's own credential precedence.
- `dot_claude/skills/symlink_*` — one symlink per personal skill, pointing into the `~/.local/share/claude-skills` external. Skills are checked out there rather than straight into `~/.claude/skills` because that directory also holds skills from other tooling (a git-repo external would claim the whole directory) and Claude Code only discovers skills exactly one level deep. Adding a skill to the private repo means adding a matching `symlink_<name>` file here.

Related: `rc.d/85-functions.zsh` wraps `claude` in a function that runs it with `ANTHROPIC_API_KEY` and `DO_NOT_TRACK` unset for that process only — the key would bill the API instead of the subscription, and `DO_NOT_TRACK` disables the feature-flag evaluation Remote Control needs. Both stay exported for every other tool.

**Git config is XDG-only.** `dot_config/git/config` → `~/.config/git/config` is the single source of truth; a `~/.gitconfig` must never be created, because git prefers it and would silently shadow this file. Commit signing is opt-in per commit (`-S`), through 1Password's `op-ssh-sign`; `gh` serves credentials for github.com. Everything in that file is public and safe to commit.

**PATH hygiene lives in `.zshenv`.** `typeset -U path PATH` is set there — before any prepend runs — so re-entrant shells (`exec zsh`, sourcing `.zshrc` again, a login shell inside a login shell) don't stack duplicates from `brew shellenv` and `25-local-bin`. `~/.local/bin` (uv's tool shims) is prepended *after* brew's shellenv so a uv-installed tool wins over a formula of the same name.

**`_fzf_preview` must stay in `.zshenv`, not `.zshrc`.** It's the single preview dispatcher shared by CTRL-T, ALT-C and every fzf-tab completion (dir → eza, text → bat, image → chafa, other binary → hexyl), and fzf renders previews in a *non-interactive* zsh, which never reads `.zshrc`.

**macOS defaults are a `run_once_` script.** `run_once_before_macos-defaults.sh` writes user-domain `defaults` only (no sudo) and no-ops off macOS. It is idempotent, but chezmoi tracks it by content hash: editing it re-runs the whole script on the next apply.

**The repo is a PUBLIC GitHub repo, so anything reconnaissance-sensitive is age-encrypted, not committed in the clear.** `~/.ssh/config` (internal hostnames, IPs, users) lives in source as `private_dot_ssh/encrypted_private_config.age`. Encryption config is in `.chezmoi.toml.tmpl` (`encryption = "age"` + a public `recipient` — safe to commit). The **private** age identity lives only at `~/.config/chezmoi/key.txt` and in 1Password (document `chezmoi-age-key`, Private vault); it is never committed. To edit the ssh config, use `chezmoi edit ~/.ssh/config` (chezmoi decrypts, you edit plaintext, it re-encrypts). To manage another sensitive file the same way: `chezmoi add --encrypt <path>`.

The ssh setup pins one identity per host (`IdentityFile` + `IdentitiesOnly`), because the 1Password agent serves several keys in its own order — GitHub would authenticate as whichever it accepted first, and the NAS's sshd ran out of attempts before a password was offered. The second GitHub identity needs a host alias *and* its own `ControlPath`: `%C` hashes the resolved hostname, identical for both aliases, so a shared path would reuse the other's master connection and with it the wrong identity. The public halves live in source as `encrypted_*.pub.age` — not because public keys are secret, but because chezmoi encrypts contents and not names, so the names are themselves disclosure; they are named for their role here, deliberately.

Those `ControlPath`s need `~/.ssh/control/` to exist — ssh creates the sockets but never the directory, so without it every connection on a fresh machine dies with `unix_listener: cannot bind to path`. It is managed as `private_dot_ssh/private_control/empty_dot_keep`: an empty `.keep` only because git drops empty directories, and the directory is deliberately **not** `exact_`, which would make chezmoi delete the live control sockets on every apply.

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
