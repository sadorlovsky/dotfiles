# =========================================================
# zsh-ai (Anthropic Claude — native provider)
# =========================================================

export ZSH_AI_PROVIDER="anthropic"
export ZSH_AI_ANTHROPIC_MODEL="claude-haiku-4-5"
[[ -f ${ZDOTDIR:-~}/secrets.zsh ]] && source ${ZDOTDIR:-~}/secrets.zsh
export ZSH_AI_PROMPT_EXTEND='Target system is macOS (Darwin) with BSD userland, not GNU/Linux. Output ONLY BSD/macOS-compatible syntax, one command. Rules: (1) Never use GNU-only flags; use sed -i with an empty backup arg: sed -i "" . (2) Never produce interactive or long-running commands (no bare top, no tail -f, no watch) for one-shot requests. (3) To list/sort processes by memory or CPU use ps piped to sort/head, NOT top. Example memory top-5: ps -Ao %mem,pid,user,comm -m | head -6 ; for CPU use -r instead of -m. (4) To kill a process by listening port use: lsof -ti tcp:PORT | xargs kill . (5) Do not append words from the request into filenames, globs, or flags.'
[[ -f "$BREW_PREFIX/share/zsh-ai/zsh-ai.plugin.zsh" ]] && source "$BREW_PREFIX/share/zsh-ai/zsh-ai.plugin.zsh"
