# 🌟 Zach's dotfiles

Personal dotfiles for a fast, XDG-clean, and good-looking terminal environment.
Managed with [chezmoi](https://www.chezmoi.io/).

![WezTerm](https://img.shields.io/badge/Terminal-WezTerm-orange)
![ZSH](https://img.shields.io/badge/Shell-ZSH-yellow)
![Starship](https://img.shields.io/badge/Prompt-Starship-ff69b4)

## 📦 What's inside

| Path | What |
|------|------|
| `~/.config/zsh/.zshenv` | XDG base dirs, `EDITOR`/`VISUAL`, per-shell env |
| `~/.config/zsh/.zprofile` | Homebrew shell env (login shells) |
| `~/.config/zsh/.zshrc` | Interactive shell: history, completion, plugins, aliases |
| `~/.config/wezterm/wezterm.lua` | WezTerm: runtime theme switcher + auto light/dark |
| `~/.config/starship.toml` | Starship prompt |

ZSH lives under `~/.config/zsh` via `ZDOTDIR`, so `$HOME` stays clean. No plugin
manager — plugins are installed with Homebrew and sourced directly.

## 🚀 Tools

- [Starship](https://starship.rs/) — prompt
- [zoxide](https://github.com/ajeetdsouza/zoxide) — smarter `cd`
- [fzf](https://github.com/junegunn/fzf) + [fd](https://github.com/sharkdp/fd) — fuzzy finder
- [fzf-tab](https://github.com/Aloxaf/fzf-tab) — fuzzy completion menu
- [eza](https://github.com/eza-community/eza) — `ls` replacement
- [bat](https://github.com/sharkdp/bat) — `cat`/pager with syntax highlighting
- [vivid](https://github.com/sharkdp/vivid) — `LS_COLORS` generator
- zsh-autosuggestions, zsh-syntax-highlighting, zsh-history-substring-search
- [WezTerm](https://wezfurlong.org/wezterm/) — GPU-accelerated terminal

## 🎨 Theming

Colors follow the macOS light/dark system appearance automatically:

- **WezTerm** — a "minimal" theme family auto-switches with the OS; `CTRL+SHIFT+T`
  opens a fuzzy theme picker.
- **`LS_COLORS`** (eza + completion) — dark → `catppuccin-mocha`, light → `gruvbox-light-hard`.
- **Claude Code** — `COLORFGBG` is set from the system appearance so its `auto`
  theme tracks the OS instead of getting stuck on light.

## 🔧 Setup on a new machine

1. Install [chezmoi](https://www.chezmoi.io/) and apply the dotfiles:
   ```sh
   brew install chezmoi
   chezmoi init --apply sadorlovsky
   ```

2. Install the tools:
   ```sh
   brew install starship zoxide fzf fd eza bat vivid \
     zsh-autosuggestions zsh-syntax-highlighting zsh-history-substring-search
   ```

3. Clone `fzf-tab` (not on Homebrew):
   ```sh
   git clone --depth 1 https://github.com/Aloxaf/fzf-tab.git \
     ~/.local/share/zsh/plugins/fzf-tab
   ```

4. Bootstrap `ZDOTDIR` so zsh finds its config under `~/.config/zsh`.
   This is a system file outside `$HOME`, so it isn't managed by chezmoi —
   create it once (requires `sudo`):
   ```sh
   sudo tee /etc/zshenv > /dev/null << 'EOF'
   if [[ -z "$XDG_CONFIG_HOME" ]]; then
       export XDG_CONFIG_HOME="$HOME/.config"
   fi
   if [[ -d "$XDG_CONFIG_HOME/zsh" ]]; then
       export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
   fi
   EOF
   ```

5. Fonts used by WezTerm: **Fairfax Hax** and **JetBrains Mono** Nerd Font.

## 🔄 Updates

```sh
chezmoi update -v      # pull latest and apply
chezmoi add <file>     # stage a locally-changed dotfile back into the repo
chezmoi cd             # open a shell in the source dir to commit & push
```

## 📄 License

MIT
