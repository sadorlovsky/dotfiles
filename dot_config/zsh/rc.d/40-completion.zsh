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
# Must be loaded AFTER compinit, BEFORE plugins that wrap widgets (autosuggestions, syntax-highlighting)
source "$XDG_DATA_HOME/zsh/plugins/fzf-tab/fzf-tab.plugin.zsh"
zstyle ':fzf-tab:*' switch-group '<' '>'   # switch groups with < / >
# Smart preview: directory -> eza, file -> bat, anything else -> plain text
zstyle ':fzf-tab:complete:*' fzf-preview '
  if [[ -d $realpath ]]; then
    eza -1 --color=always $realpath
  elif [[ -f $realpath ]]; then
    bat --color=always --style=plain,numbers --line-range=:500 $realpath
  else
    echo $realpath
  fi
'
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
