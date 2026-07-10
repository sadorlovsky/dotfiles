# =========================================================
# Terminal title  (show cwd in the WezTerm tab instead of just "zsh")
# =========================================================

autoload -Uz add-zsh-hook

# On each prompt: set the title to the current directory (~-abbreviated)
_title_precmd() { print -Pn '\e]0;%~\a' }
add-zsh-hook precmd _title_precmd

# While a command runs: show the running command name instead
_title_preexec() { print -Pn '\e]0;'; print -rn -- "${1%% *}"; print -n '\a' }
add-zsh-hook preexec _title_preexec
