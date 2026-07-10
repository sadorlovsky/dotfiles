# ROADMAP

Planned changes to these dotfiles. Each item is a self-contained task with context and concrete steps.

---

## git: per-context identity via `includeIf`

**What.** Split git identity by directory so work repos automatically use a work email/signing key, personal repos the default. Inspired by holman/dotfiles' `[include] path = ~/.gitconfig.local` pattern, upgraded to conditional includes.

**Why.** Avoid committing to a work repo with the personal `sadorlovsky@gmail.com`, and vice-versa. Only worth doing once a second (work) context exists.

**Steps.**

1. In `dot_config/git/config`, append after `[user]`:
   ```ini
   [includeIf "gitdir:~/work/"]
       path = ~/.config/git/work.config
   ```
2. Create `dot_config/git/work.config` with just the override:
   ```ini
   [user]
       email = <work-email>
       signingkey = <work-ssh-key>
   ```
   If the work email is non-sensitive it can be committed; otherwise render it via a chezmoi template / 1Password like `private_secrets.zsh.tmpl`.
3. Verify: `cd ~/work/somerepo && git config user.email` shows the work address; elsewhere the default.

**Note.** `includeIf "gitdir:"` needs a trailing slash to match a directory tree. Order matters — later includes win, so keep the conditional block after the base `[user]`.

---

## Screenshots → iCloud Drive (instead of Desktop)

**What.** Point `com.apple.screencapture location` at an iCloud Drive folder so screenshots don't clutter the Desktop and sync across devices. Deferred from the macOS-defaults curation.

**Why.** User dislikes screenshots piling up on the Desktop.

**Steps.** Add to `run_once_before_macos-defaults.sh` (or a small dedicated script):
```sh
mkdir -p "${HOME}/Library/Mobile Documents/com~apple~CloudDocs/Screenshots"
defaults write com.apple.screencapture location \
  -string "${HOME}/Library/Mobile Documents/com~apple~CloudDocs/Screenshots"
defaults write com.apple.screencapture type -string "png"
defaults write com.apple.screencapture disable-shadow -bool true
killall SystemUIServer
```

**Watch out.**
- The iCloud path contains a space (`Mobile Documents`), so `~` won't expand — use the full `${HOME}/…` quoted.
- Screenshots then upload to iCloud and count against quota; if you shoot in bursts that's noticeable.
- Editing `run_once_before_macos-defaults.sh` changes its hash, so chezmoi re-runs the whole script on next `apply` (fine — it's idempotent).

---

## atuin: configuration (`config.toml`)

atuin is **installed and wired** (`rc.d/55-atuin.zsh`, `brew "atuin"`, history imported). Ctrl-R → atuin, Up/Down → zsh-history-substring-search. Next: add a config file to tune it to taste.

**Steps.** Add `dot_config/atuin/config.toml` as chezmoi source state (XDG maps directly: `dot_config/atuin/config.toml` → `~/.config/atuin/config.toml`). Starter worth reviewing:
```toml
# ~/.config/atuin/config.toml
style = "compact"                              # or "full"
inline_height = 20                             # don't take the whole screen
filter_mode = "global"                         # Ctrl-R default scope
filter_mode_shell_up_key_binding = "directory" # (only relevant if up-arrow is given to atuin)
show_preview = true
enter_accept = false                           # Enter edits the line, doesn't run it (safer)
```
Decisions to make when doing it: search style (`compact`/`full`), default `filter_mode` (global vs directory vs session), and `enter_accept` behaviour. Keep it small — only override what differs from defaults.

## atuin: cross-machine sync (optional)

Only worth it with a second machine. `atuin register`/`login` (hosted or self-hosted). The encryption key (`atuin key`) is a **secret**: store in 1Password and render via a chezmoi template like `private_secrets.zsh.tmpl`. Never commit it in plaintext.

## WezTerm: fuzzy SSH host picker keybinding

The `ssh_domains` (auto-generated in `modules/ssh.lua` from `~/.ssh/config`) currently have **no launcher keybinding** — you reach them via `wezterm connect <host>` or the Command Palette (`Ctrl+Shift+P`). Add a key that opens a fuzzy picker of just the SSH domains.

**Steps.** In `dot_config/wezterm/modules/keys.lua`, bind a key to:
```lua
wezterm.action.ShowLauncherArgs({ flags = "FUZZY|DOMAINS" })
```
**Pick a free key** — `Ctrl+Shift+L` is already `ShowDebugOverlay` (WezTerm default), so don't use it. Candidates: `CMD+Shift+S`, `Ctrl+Shift+U`, or a leader-key chord if you use one.

**Notes.**
- Connecting logs a harmless warning: `WEZTERM_REMOTE_PANE setenv failed … AcceptEnv`. To silence it (optional, only on servers you own like `mastodon`): add `AcceptEnv WEZTERM_*` to the remote `/etc/ssh/sshd_config` and reload sshd.
- Current domains use `multiplexing = "None"` (no remote install needed, but no persistence). If you ever want tmux-like persistent remote sessions, switch a domain to `multiplexing = "WezTerm"` and install `wezterm` on that host.

## Sandboxed "YOLO" Claude Code (`sb`)

**What.** A shell wrapper that runs `claude --dangerously-skip-permissions` inside a sandbox jail with per-project allow-profiles, so you get the fast no-confirmation flow without giving the agent unrestricted access to the machine. Idea + reference implementation from statico/dotfiles.

**Why.** You run Claude Code a lot; `--dangerously-skip-permissions` is fast but scary. A sandbox constrains what the agent can touch (filesystem, network) per project.

**Tool.** [nono.sh](https://nono.sh) — a macOS sandbox runner (uses Apple's `sandbox-exec` under the hood) with JSON allow-profiles.

**Reference implementation** (statico/dotfiles):
- `sb()` wrapper: <https://github.com/statico/dotfiles/blob/main/.zshrc#L470-L484> — runs `nono run --profile <name> --suppress-save-prompt / -- env DISABLE_AUTOUPDATER=1 claude --dangerously-skip-permissions "$@"`.
- `_sb` completion: <https://github.com/statico/dotfiles/blob/main/.zshrc#L794> — completes the profile arg from `~/.config/nono/profiles/*.json`.

**Steps.**
1. Install nono (check current install method on nono.sh — Homebrew tap or script).
2. Add `sb()` + `_sb` completion as a new `dot_config/zsh/rc.d/NN-agents.zsh` (topic file).
3. Create per-project profiles under `dot_config/nono/profiles/*.json`, chezmoi-managed (XDG → `~/.config/nono/profiles/`). Start restrictive (project dir + needed network), loosen as needed.

**Caveats.** nono is young — evaluate maturity before trusting it as a security boundary; `sandbox-exec` itself is deprecated-but-functional on macOS. Treat it as defense-in-depth, not a hard guarantee.

## Cross-platform: zsh on Linux SSH hosts (OS-gated chezmoi)

**Goal.** Run chezmoi on Linux SSH hosts and deploy the **full** zsh experience there (plugins included), while the 3 personal MacBooks keep the macOS-only bits. All three Macs share one config, so the split is purely **`.chezmoi.os` (darwin vs linux)** — no per-machine tags needed.

**Substrate.** The `rc.d/NN-*.zsh` topic split is already ideal: gate whole topics per OS via `.chezmoiignore.tmpl`.

**Topic portability:**
- Portable as-is: `00-history`, `10-options`, `15-privacy`, `60-keybindings`, `85-functions` (jqi).
- macOS-only (drop on Linux): `30-appearance` (`defaults read AppleInterfaceStyle`), `80-wezterm` (app path), and the whole `dot_config/wezterm/`.
- Needs an OS-aware variant: `20-homebrew`, `40-completion`, `50-tools`, `55-atuin`, `90-aliases` — they assume Homebrew paths / macOS.

**Key open decision — how plugins/tools install on Linux** (pick before building):
- **Option A (server-friendly, recommended):** clone zsh plugins (fzf-tab already; add autosuggestions/syntax-highlighting/history-substring-search) via `.chezmoiexternal.toml` into `$XDG_DATA_HOME/zsh/plugins/` on **all** OSes, and refactor `50-tools`/`40-completion` to source from that XDG dir instead of `$BREW_PREFIX/share`. Install the binaries (atuin/starship/fzf/zoxide/eza/bat/fd) via **mise** or official installers on Linux. No linuxbrew on servers.
- **Option B:** install linuxbrew on the servers and reuse `$(brew --prefix)/share/...` paths (minimal code change, heavy server dependency).

**Steps (after deciding A/B):**
1. `.chezmoi.toml.tmpl`: expose `os` in `[data]` (or just use `.chezmoi.os` directly in templates).
2. `.chezmoiignore.tmpl`: `{{ if ne .chezmoi.os "darwin" }}` block dropping the macOS-only topics + `dot_config/wezterm`.
3. OS-aware Brewfile: the `run_onchange` installer already uses a heredoc — template it so Linux installs a **subset** (no casks/fonts) or skips brew entirely (Option A).
4. Make plugin sourcing path-agnostic per the chosen option.
5. Test: `chezmoi init` on one Linux host, confirm only portable topics land and the shell starts clean.
