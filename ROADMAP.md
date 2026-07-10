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

## atuin: remaining optional follow-ups

atuin itself is **installed and wired** (`rc.d/55-atuin.zsh`, `brew "atuin"`, history imported). Ctrl-R → atuin, Up/Down → zsh-history-substring-search. Optional extras not yet done:

- **`dot_config/atuin/config.toml`** — tune search UX (e.g. `style = "compact"`, `inline_height = 20`, `filter_mode = "global"`, `filter_mode_shell_up_key_binding = "directory"`). XDG path maps directly: `dot_config/atuin/config.toml` → `~/.config/atuin/config.toml`.
- **Cross-machine sync** — `atuin register`/`login` (hosted or self-hosted). The encryption key (`atuin key`) is a **secret**: store in 1Password and render via a chezmoi template like `private_secrets.zsh.tmpl`. Never commit it in plaintext. Only worth it with a second machine.
