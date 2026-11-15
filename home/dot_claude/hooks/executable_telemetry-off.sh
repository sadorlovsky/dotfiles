#!/bin/zsh -f
# Claude Code PostToolUse hook (matcher: Bash), wired in by
# dot_claude/modify_settings.json.
#
# After Claude runs an install command, apply known telemetry opt-outs right
# away (the launchd watcher would too, a few seconds later — they share a lock
# and a seen-list, so whichever runs first does the work) and tell Claude about
# anything installed without an opt-out on record, so it can research it in
# the same session via the disable-telemetry skill.
#
# Never blocks or fails the tool call: every exit path is 0.

T=$HOME/.config/telemetry-off/telemetry-off
[[ -x $T ]] || exit 0

cmd=$(/opt/homebrew/bin/jq -r '.tool_input.command // empty' 2>/dev/null) || exit 0
[[ -n $cmd ]] || exit 0

# Install commands across the package managers telemetry-off inventories.
if ! print -r -- "$cmd" | grep -Eq \
  '(^|[;&|[:space:]])(brew[[:space:]]+(install|reinstall|bundle)|mas[[:space:]]+install|mise[[:space:]]+(use|install)|uv[[:space:]]+tool[[:space:]]+install|npm[[:space:]]+(i|install|add)[[:space:]].*(-g|--global)|bun[[:space:]]+(add|install)[[:space:]].*(-g|--global))'
then
  exit 0
fi

$T watch --quiet >/dev/null 2>&1
# Window, not "this run only": if launchd beat us to it, its events are still
# what this install caused. Short, so unrelated manual `apply` runs stay out.
recent=$($T recent 120 2>/dev/null | awk -F'\t' '($2=="applied"||$2=="manual"||$2=="failed") && !seen[$2 $3 $4]++ {print "- " $2 ": " $3 " — " $4}')
pending=$($T pending --since 900 2>/dev/null | awk -F'\t' '{print "- " $2 " (" $1 ")"}')

[[ -z $recent && -z $pending ]] && exit 0

msg="telemetry-off ran after this install."
[[ -n $recent  ]] && msg+=$'\n'"Opt-outs applied in the last 2 min:"$'\n'"$recent"
[[ -n $pending ]] && msg+=$'\n'"Newly installed with NO known telemetry opt-out:"$'\n'"$pending"$'\n'"Use the disable-telemetry skill to research these, add them to the database, and apply."

/opt/homebrew/bin/jq -n --arg m "$msg" \
  '{hookSpecificOutput: {hookEventName: "PostToolUse", additionalContext: $m}}'
exit 0
