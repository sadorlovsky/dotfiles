# =========================================================
# Completion  (must run before tools that register compdef, e.g. fzf)
# =========================================================

autoload -Uz compinit
_zcompdump="$XDG_CACHE_HOME/zsh/zcompdump"
if [[ -n $_zcompdump(#qN.mh+24) ]]; then
  compinit -d "$_zcompdump"       # dump older than 24h: full security check + rebuild
else
  compinit -C -d "$_zcompdump"    # dump fresh: skip the check for a faster start
fi
unset _zcompdump

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'  # case-insensitive: "doc" -> "Documents"
zstyle ':completion:*' menu no                          # let fzf-tab handle the menu
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}   # colorize completion entries

# fzf-tab: replace the completion menu with an fzf fuzzy picker
# Must be loaded AFTER compinit, BEFORE plugins that wrap widgets (autosuggestions, syntax-highlighting).
# Guarded: if the external clone hasn't landed yet (mid-bootstrap), skip it — the
# zstyles below are harmless no-ops without the plugin.
[[ -r "$XDG_DATA_HOME/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh" ]] && \
  source "$XDG_DATA_HOME/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh"
zstyle ':fzf-tab:*' switch-group '<' '>'   # switch groups with < / >
# Smart preview via the shared dispatcher (defined in .zshenv) — same rich
# preview as CTRL-T / ALT-C: dir -> eza, text -> bat, image -> chafa, bin -> hexyl.
zstyle ':fzf-tab:complete:*' fzf-preview '_fzf_preview $realpath'

# Per-command context previews (candidate is $word for non-path completions).
zstyle ':fzf-tab:complete:man:*' fzf-preview \
  'man $word 2>/dev/null | col -bx | bat -l man --color=always -p 2>/dev/null || man $word'
zstyle ':fzf-tab:complete:(brew|brew-install|brew-uninstall|brew-info):*' fzf-preview \
  'brew info $word 2>/dev/null'
zstyle ':fzf-tab:complete:(kill|killall):*' fzf-preview \
  'ps -Ao pid,pcpu,pmem,comm | grep -i -- $word 2>/dev/null'
zstyle ':fzf-tab:complete:git-(checkout|switch|log|show|rebase|merge|branch):*' fzf-preview \
  'git log --oneline --graph --color=always -20 $word 2>/dev/null'
# Auto-hide the preview pane for non-path candidates (flags, subcommands, etc.),
# so their descriptions get the full width instead of being squeezed + truncated.
# fzf-tab packs each candidate as NUL-delimited fields; field 2 ({2}) is the
# display string. Described candidates carry a description + alignment padding
# (fzf-tab generates the list at COLUMNS=500), so they either start with '-'
# (flags) or contain a run of spaces (word + padding + description); bare file /
# dir names have neither. `result` covers the initial render, `focus` arrow moves.
zstyle ':fzf-tab:complete:*' fzf-flags \
  --preview-window='right:55%:wrap' \
  --bind='result:transform:[[ {2} == -* || {2} == *"  "* ]] && echo "change-preview-window(hidden)" || echo "change-preview-window(right,55%,wrap)"' \
  --bind='focus:transform:[[ {2} == -* || {2} == *"  "* ]] && echo "change-preview-window(hidden)" || echo "change-preview-window(right,55%,wrap)"'
