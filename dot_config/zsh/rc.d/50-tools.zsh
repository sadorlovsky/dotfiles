# =========================================================
# Prompt & tools
# Load order is load-bearing: starship/fzf/zoxide, then autosuggestions,
# then syntax-highlighting, then history-substring-search LAST.
# =========================================================

# Starship prompt
eval "$(starship init zsh)"

# fzf
# Use fd for file lists (respects .gitignore, includes hidden, strips ./)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='
  --height=60%
  --layout=reverse
  --border=rounded
  --prompt="> "
  --pointer="▶"
  --marker="+"
'
# Preview file contents with bat on Ctrl-T
export FZF_CTRL_T_OPTS="--preview 'bat --color=always --style=plain,numbers --line-range=:500 {}'"
# Key bindings (Ctrl-T, Ctrl-R, Alt-C) + completion
# NOTE: Ctrl-R here is later overridden by atuin (55-atuin.zsh).
source <(fzf --zsh)

# zoxide (smart cd)
eval "$(zoxide init --cmd cd zsh)"

# mise (runtime version manager: node, etc.)
eval "$(mise activate zsh)"

# Autosuggestions
source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"

# Syntax highlighting — must be sourced before history-substring-search
source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
ZSH_HIGHLIGHT_STYLES[path]=none        # disable path underline
ZSH_HIGHLIGHT_STYLES[path_prefix]=none

# History substring search — must be sourced LAST (after syntax highlighting)
source "$BREW_PREFIX/share/zsh-history-substring-search/zsh-history-substring-search.zsh"
