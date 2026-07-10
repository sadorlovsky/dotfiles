# =========================================================
# System appearance  (drives eza/completion colors + Claude Code "auto" theme)
# Must run before 40-completion (list-colors reads $LS_COLORS).
# =========================================================

# Detected once at shell startup; open a new shell after switching light/dark.
# COLORFGBG lets tools (Claude Code, vim, ...) know the background without an OSC 11 query.
if [[ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" == Dark ]]; then
  export LS_COLORS="$(vivid generate catppuccin-mocha)"    # dark
  export COLORFGBG="15;0"                                  # light fg on dark bg
  export BAT_THEME="Catppuccin Mocha"                      # drives bat + git-delta
else
  export LS_COLORS="$(vivid generate gruvbox-light-hard)"  # light (high contrast)
  export COLORFGBG="0;15"                                  # dark fg on light bg
  export BAT_THEME="gruvbox-light"                         # drives bat + git-delta
fi
