# =========================================================
# Homebrew  (BREW_PREFIX is used by later topics that source $BREW_PREFIX/share)
# =========================================================

# Guarded so a machine without Homebrew (mid-bootstrap, or a stripped host) still
# opens a clean shell: BREW_PREFIX stays unset and the topics that source
# $BREW_PREFIX/share below all test for the file first.
if command -v brew >/dev/null 2>&1; then
  BREW_PREFIX="$(brew --prefix)"

  export HOMEBREW_NO_ANALYTICS=1
  export HOMEBREW_NO_INSTALL_CLEANUP=1   # no automatic cleanup after install/upgrade
  export HOMEBREW_NO_ENV_HINTS=1         # silence environment hint messages
  export HOMEBREW_NO_AUTO_UPDATE=1       # skip automatic brew update before install/upgrade
fi
