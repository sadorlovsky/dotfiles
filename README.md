# 🌟 Zach's dotfiles

Personal dotfiles for a fast, XDG-clean, and good-looking terminal environment.
Managed with [chezmoi](https://www.chezmoi.io/).

![WezTerm](https://img.shields.io/badge/Terminal-WezTerm-orange)
![ZSH](https://img.shields.io/badge/Shell-ZSH-yellow)
![Starship](https://img.shields.io/badge/Prompt-Starship-ff69b4)

## 📦 What's inside

| Path | What |
|------|------|
| `~/.zshenv` | Bootstrap: sets `ZDOTDIR` to `~/.config/zsh`, then sources the config below |
| `~/.config/zsh/.zshenv` | XDG base dirs, `EDITOR`/`VISUAL`, per-shell env |
| `~/.config/zsh/.zprofile` | Homebrew shell env (login shells) |
| `~/.config/zsh/.zshrc` | Loader only — sources the topic files below in order |
| `~/.config/zsh/rc.d/NN-*.zsh` | The actual interactive config, one file per topic |
| `~/.config/wezterm/` | WezTerm: thin `wezterm.lua` + `modules/` (general, theme, tabbar, keys, mouse, links, ssh) |
| `~/.config/starship.toml` | Starship prompt |
| `~/.config/git/config` | Global git config (XDG; there is intentionally no `~/.gitconfig`) |
| `~/.config/helix/` | Helix (`$EDITOR`) config, per-language overrides, transparent theme |
| `~/.claude/` | Claude Code: global `CLAUDE.md`, statusline, `settings.json` patch, personal skills |
| `~/.ssh/config` | Age-encrypted in the repo — hostnames stay out of a public repo |

ZSH lives under `~/.config/zsh` via `ZDOTDIR`, keeping `$HOME` clean — the only
zsh file left in `$HOME` is `~/.zshenv`, a tiny bootstrap that redirects there.
No plugin manager — plugins are installed with Homebrew and sourced directly.

## 🚀 Tools

- [Starship](https://starship.rs/) — prompt
- [zoxide](https://github.com/ajeetdsouza/zoxide) — smarter `cd`
- [fzf](https://github.com/junegunn/fzf) + [fd](https://github.com/sharkdp/fd) — fuzzy finder
- [fzf-tab](https://github.com/Aloxaf/fzf-tab) — fuzzy completion menu
- [atuin](https://atuin.sh/) — SQLite-backed history; owns `CTRL-R` (Up/Down stay on substring search)
- [eza](https://github.com/eza-community/eza) — `ls` replacement
- [bat](https://github.com/sharkdp/bat) — `cat`/pager with syntax highlighting
- [ripgrep](https://github.com/BurntSushi/ripgrep) + [jq](https://jqlang.github.io/jq/) — search and JSON (`jqi` builds a jq filter interactively in fzf)
- [chafa](https://hpjansson.org/chafa/) + [hexyl](https://github.com/sharkdp/hexyl) — image and binary previews in fzf / fzf-tab
- [git-delta](https://github.com/dandavison/delta) — git pager; follows `$BAT_THEME`
- [vivid](https://github.com/sharkdp/vivid) — `LS_COLORS` generator
- [Helix](https://helix-editor.com/) — `$EDITOR` (`hx`)
- [mise](https://mise.jdx.dev/) + [uv](https://docs.astral.sh/uv/) — language runtimes and Python tooling (the sanctioned non-Homebrew exception)
- [gh](https://cli.github.com/) — GitHub CLI; also serves git's credentials for github.com
- [zsh-ai](https://github.com/matheusml/zsh-ai) — natural-language command generation (Claude Haiku)
- zsh-autosuggestions, zsh-syntax-highlighting, zsh-history-substring-search
- [WezTerm](https://wezfurlong.org/wezterm/) — GPU-accelerated terminal
- [chezmoi](https://www.chezmoi.io/), [age](https://age-encryption.org/), [1Password](https://1password.com/) (app + CLI) — config, encryption, secrets

## 🎨 Theming

Colors follow the macOS light/dark system appearance automatically:

- **WezTerm** — a "minimal" theme family auto-switches with the OS; `CTRL+SHIFT+T`
  opens a fuzzy theme picker.
- **`LS_COLORS`** (eza + completion) — dark → `catppuccin-mocha`, light → `gruvbox-light-hard`.
- **`BAT_THEME`** (bat, and git-delta through it) — dark → Catppuccin Mocha,
  light → gruvbox-light.
- **Claude Code** — `COLORFGBG` is set from the system appearance so its `auto`
  theme tracks the OS instead of getting stuck on light.

The shell reads the appearance once at startup, so open a new shell after
flipping light/dark. Helix is the exception: it has no runtime theme switch and
pins the dark theme (see [ROADMAP](ROADMAP.md)).

## 🔧 Setup on a new machine

One command, from a clean macOS install:

```sh
sh -c "$(curl -fsLS https://dotfiles.orlovsky.dev)"
```

[`install.sh`](install.sh) is idempotent and takes the machine end to end:

1. **Xcode Command Line Tools** → **Homebrew** (installs each only if missing).
2. **chezmoi + age + 1Password CLI/app** — the tools needed before the first apply.
3. Pauses until you **sign in to 1Password** (enable *Settings → Developer →
   Integrate with 1Password CLI*, then unlock). This is the one unavoidable
   manual step — it backs both the age key and `secrets.zsh`.
4. **`chezmoi init --apply sadorlovsky`**, which then:
   - fetches the **age key** from 1Password (`chezmoi-age-key`, Private vault) via
     a `run_before` script — needed to decrypt `~/.ssh/config`;
   - **installs every Homebrew package + font** (`run_onchange` → `brew bundle`);
   - **clones the externals** — `fzf-tab` and the private personal
     Claude Code skills repo (`.chezmoiexternal.toml`);
   - points `ZDOTDIR` at `~/.config/zsh` via the managed `~/.zshenv`.

Re-running the one-liner (or `chezmoi apply`) is safe — every step skips work
already done.

Keep 1Password **unlocked** for a full apply: rendering `secrets.zsh` goes
through the app. If the app isn't running, `.chezmoiignore` skips that one file
instead of hanging the apply, leaving any previously rendered copy in place.
The skills external is cloned over SSH, so on a brand-new machine it fails on
the first apply (the ssh config lands in the same run) and succeeds on the
second.

### Prefer to do it by hand?

```sh
brew install chezmoi age 1password-cli   # + install the 1Password app and sign in
chezmoi init --apply sadorlovsky         # age key is fetched from 1Password automatically
```

If the age key can't be fetched (no 1Password), place it manually first:
```sh
op document get chezmoi-age-key --vault Private > ~/.config/chezmoi/key.txt
chmod 600 ~/.config/chezmoi/key.txt
```

### Automation

- **`install.sh`** — the bootstrap above (repo root, outside chezmoi's source).
- **`run_before_00-fetch-age-key.sh.tmpl`** — provisions the age key from
  1Password before any encrypted file is read (no-ops once the key exists).
- **`run_onchange_before_install-packages.sh`** — runs `brew bundle` with the
  package list; re-runs automatically whenever that list changes.
- **`run_once_before_macos-defaults.sh`** — curated `defaults write` settings
  (typing, Finder, Dock, software update); user domain only, no sudo.
- **`.chezmoiexternal.toml`** — clones/updates `fzf-tab` and the private
  personal Claude Code skills repo (both refreshed weekly).
- **`dot_claude/modify_settings.json`** — a chezmoi `modify_` script that patches
  only the keys we own into `~/.claude/settings.json`, which Claude Code rewrites
  at runtime.

Fonts (**Fairfax** + **JetBrains Mono**) install automatically via `brew bundle`.

## 🔄 Updates

```sh
chezmoi update -v      # pull latest and apply
chezmoi add <file>     # stage a locally-changed dotfile back into the repo
chezmoi cd             # open a shell in the source dir to commit & push
```

## 📄 License

MIT
