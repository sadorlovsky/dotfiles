# =========================================================
# WezTerm shell integration  (OSC 133 semantic zones)
# =========================================================
# Marks prompt/command zones so WezTerm can jump between prompts (Shift+Up/Down)
# and select a whole command's output (triple-click). Only inside WezTerm.
if [[ "$TERM_PROGRAM" == "WezTerm" ]]; then
  for _wz in \
    "/Applications/WezTerm.app/Contents/Resources/wezterm.sh" \
    "${HOMEBREW_PREFIX:-/opt/homebrew}/share/wezterm/wezterm.sh"; do
    [[ -r "$_wz" ]] && { source "$_wz"; break; }
  done
  unset _wz
fi
