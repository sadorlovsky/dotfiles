# =========================================================
# atuin  (SQLite-backed shell history with fuzzy search)
# Loads AFTER fzf so atuin's Ctrl-R wins. --disable-up-arrow keeps Up/Down on
# zsh-history-substring-search (bound in 60-keybindings); atuin owns Ctrl-R only.
# =========================================================

if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh --disable-up-arrow)"
fi
