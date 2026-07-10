# =========================================================
# Shell functions
# =========================================================

# jqi — interactive jq filter builder in fzf.
#   jqi data.json      # explore a file
#   curl … | jqi       # explore piped JSON
# Type a jq filter and watch the result update live; Enter prints the final
# filter to stdout (compose it: `filter=$(jqi data.json)`). Needs fzf + jq.
jqi() {
  emulate -L zsh
  local tmp filter
  tmp=$(mktemp) || return 1
  if [[ -n $1 ]]; then
    cat -- "$1" > "$tmp"
  else
    cat > "$tmp"          # read piped JSON from stdin
  fi
  filter=$(
    echo | fzf --print-query --query='.' --prompt='jq> ' \
      --height='90%' --info=inline --preview-window='up:99%:wrap' \
      --preview "jq --color-output {q} < ${(q)tmp} 2>&1" \
    | head -1
  )
  rm -f -- "$tmp"
  [[ -n $filter ]] && print -r -- "$filter"
}
