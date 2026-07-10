# =========================================================
# Key bindings
# =========================================================

# Up/Down: search history for entries containing the typed text (substring)
bindkey '^[[A' history-substring-search-up      # Up
bindkey '^[[B' history-substring-search-down    # Down
# Also bind the terminfo sequences (application/keypad mode)
[[ -n ${terminfo[kcuu1]} ]] && bindkey "${terminfo[kcuu1]}" history-substring-search-up
[[ -n ${terminfo[kcud1]} ]] && bindkey "${terminfo[kcud1]}" history-substring-search-down
