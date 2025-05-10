# 🌟 Zach's dotfiles

My personal dotfiles for creating a productive and aesthetically pleasing development environment.

![Catppuccin Macchiato](https://img.shields.io/badge/Theme-Catppuccin_Macchiato-blue)
![WezTerm](https://img.shields.io/badge/Terminal-WezTerm-orange)
![ZSH](https://img.shields.io/badge/Shell-ZSH-yellow)

## ✨ Features

- **Minimal & clean**: Focused configurations without unnecessary bloat
- **Modern shell**: ZSH with Zap plugin manager for speed and convenience
- **Elegant terminal**: WezTerm with custom bottom bar and Catppuccin theme

## 📦 What's inside

- `.zshrc` - ZSH configuration with zap, syntax highlighting, and useful plugins
- `.wezterm.lua` - WezTerm terminal configuration with custom bar and theme

## 🚀 Key tools

- [Zap](https://github.com/zap-zsh/zap) - Lightning fast ZSH plugin manager
- [Starship](https://starship.rs/) - Customizable cross-shell prompt
- [Zoxide](https://github.com/ajeetdsouza/zoxide) - Smarter cd command
- [fzf](https://github.com/junegunn/fzf) - Fuzzy finder
- [WezTerm](https://wezfurlong.org/wezterm/) - GPU-accelerated terminal emulator

## 🎨 Theme

Most components are themed with [Catppuccin Macchiato](https://github.com/catppuccin/catppuccin), a soothing pastel theme.

## 🔧 Getting Started with chezmoi

This dotfiles repository is managed with [chezmoi](https://www.chezmoi.io/), a powerful yet straightforward dotfiles manager.

### Installation

1. Install chezmoi:
   ```sh
   sh -c "$(curl -fsLS get.chezmoi.io)"
   ```
   Or use your package manager: `brew install chezmoi`, `apt install chezmoi`, etc.

2. Set up your dotfiles on a new machine with a single command:
   ```sh
   chezmoi init --apply sadorlovsky
   ```

### Updates

Pull the latest changes and apply them:
```sh
chezmoi update -v
```

## 📄 License

MIT
