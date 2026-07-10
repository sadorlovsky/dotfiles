# =========================================================
# Aliases
# =========================================================

# eza
alias ls='eza --group-directories-first'
alias ll='eza -lah --git --group-directories-first'
alias lt='eza --tree'

# bat as a quiet, cat-like replacement (no pager, no line numbers/border)
alias cat='bat --paging=never --style=plain'

# colima: nuke stuck lima sockets/pids and start fresh
alias colima-fix='pkill -9 -f "colima|lima" 2>/dev/null; rm -rf ~/.colima/_lima/_networks/ ~/.colima/_lima/colima/*.sock ~/.colima/_lima/colima/*.pid; colima start'
