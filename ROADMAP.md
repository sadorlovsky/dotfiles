# ROADMAP

Planned changes to these dotfiles. Each item is a self-contained task with context and concrete steps.

---

## [atuin](https://github.com/atuinsh/atuin) integration

**What it is.** A replacement for the standard shell history: it writes commands to SQLite instead of `$HISTFILE`, offers fuzzy search over history with filters (directory, host, exit code, duration, time), optional E2E-encrypted sync across machines, and stats. Written in Rust, installed via Homebrew.

**Why.** Cross-machine history sync and contextual search ("what did I run in this directory") — things that fzf + `zsh-history-substring-search` don't provide.

### Key risk: keybinding conflict

In the current `dot_config/zsh/dot_zshrc`, history navigation is already handled by two mechanisms:

- **`Ctrl+R`** — fzf (`source <(fzf --zsh)`, line ~110).
- **`↑` / `↓`** — `zsh-history-substring-search` (lines ~134–138).

By default `atuin init zsh` hijacks **both** `Ctrl+R` **and** `↑`. Adding it naively would cause a double hijack and break the widget chain.

**Zone-splitting solution:**

- `Ctrl+R` → **atuin** (full search with filters).
- `↑` / `↓` → stay with **`zsh-history-substring-search`** (start atuin with `--disable-up-arrow`).
- **Remove** the fzf `Ctrl+R` binding so it doesn't duplicate atuin.

### Load order (load-bearing!)

CLAUDE.md explicitly pins the plugin order, and `history-substring-search` must remain **last**. atuin registers its own ZLE widgets, so its init must go in the "Prompt & tools" block **before** autosuggestions / syntax-highlighting / history-substring-search — by analogy with zoxide/mise. After init, all that's left is rebinding `Ctrl+R` to atuin in the "Key bindings" block without touching the arrow-key bindings.

### Steps

1. **Package.** Add to `run_onchange_before_install-packages.sh` (heredoc Brewfile, "Shell tools" section):
   ```
   brew "atuin"
   ```
   Changing the script's contents itself triggers `brew bundle` on the next `chezmoi apply`.

2. **Initialization in `dot_config/zsh/dot_zshrc`.** In the "Prompt & tools" block next to zoxide/mise, respecting the order (before autosuggestions):
   ```sh
   # atuin (SQLite-backed shell history + search)
   # --disable-up-arrow: leave Up/Down to zsh-history-substring-search;
   # Ctrl-R is rebound to atuin below (fzf's Ctrl-R binding is removed).
   eval "$(atuin init zsh --disable-up-arrow)"
   ```

3. **Remove the duplicate fzf `Ctrl+R`.** `source <(fzf --zsh)` registers Ctrl+R, Ctrl+T, and Alt+C. Keep Ctrl+T and Alt+C, hand Ctrl+R to atuin. Options:
   - Keep `fzf --zsh` as is, and in the "Key bindings" block after atuin init explicitly rebind `Ctrl+R` to the atuin widget (the last `bindkey` wins), **or**
   - Set `export ZSH_FZF_HISTORY_SEARCH_BIND=` / remove the fzf binding manually.

   The first option is preferred — an explicit `bindkey '^R' atuin-search` at the end.

4. **atuin config (optional, but recommended).** Add `dot_config/atuin/config.toml` as chezmoi source state:
   ```toml
   # ~/.config/atuin/config.toml
   ## don't auto-sync history on startup (if sync isn't needed right away)
   auto_sync = false
   ## default search scope — current directory, then global
   filter_mode = "global"
   filter_mode_shell_up_key_binding = "directory"
   style = "compact"
   inline_height = 20
   ## don't store commands with a leading space (like HIST_IGNORE_SPACE)
   ```
   The XDG path is already set up (`XDG_CONFIG_HOME`), so `dot_config/atuin/config.toml` → `~/.config/atuin/config.toml`.

5. **Import existing history.** One-off manual command after installation:
   ```sh
   atuin import zsh
   ```
   (reads the current `$HISTFILE = $XDG_STATE_HOME/zsh/history`).

6. **Cross-machine sync (optional, separate step).**
   - `atuin register` / `atuin login` for their server, or self-hosted.
   - The encryption key (`atuin key`) is a secret — store it in 1Password and render via a chezmoi template, by analogy with `private_secrets.zsh.tmpl`. **Do not commit the key in plaintext.**

### Verification

- New shell starts without errors: `zsh -i -c exit`.
- `Ctrl+R` opens atuin, `↑`/`↓` still do substring search.
- `Ctrl+T` (fzf files) and `Alt+C` (fzf cd) aren't broken.
- `atuin stats` shows the imported history.

### Open questions

- Is sync needed at all, or is there just one machine? If one — skip step 6, and the feature's value drops (see discussion).
- Keep `zsh-history-substring-search` on the arrows, or hand history entirely to atuin (`↑` → atuin in directory mode)? Zone splitting is safer, but atuin-on-arrows gives a more uniform UX.
