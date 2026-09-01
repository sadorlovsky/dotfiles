# =========================================================
# User-local binaries  (~/.local/bin)
# =========================================================

# Where `uv tool install` puts its shims. uv is the sanctioned exception to
# installing everything through Homebrew (see ~/.claude/CLAUDE.md), so this
# directory has to be on PATH for those tools to be runnable at all — uv prints
# a warning and installs anyway if it isn't.
#
# Nothing else lives here. The AWS CLI used to, via Amazon's per-user installer,
# until it moved to the `awscli` formula; the leftover env/env.fish scripts are
# from the astral installer and are sourced by nothing.
#
# Prepended rather than appended, and after .zprofile's brew shellenv, so a
# uv-installed tool wins over a formula of the same name.
if [[ -d "$HOME/.local/bin" ]]; then
  path=("$HOME/.local/bin" $path)
  export PATH
fi
