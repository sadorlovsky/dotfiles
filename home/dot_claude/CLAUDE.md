# Global instructions

Personal, machine-agnostic guidance for Claude Code across all projects. Synced
to every machine via chezmoi (`home/dot_claude/CLAUDE.md` → `~/.claude/CLAUDE.md`).
Project-level `CLAUDE.md` files override this. Edit freely — this is a starter.

## Environment

- **macOS on Apple Silicon with a BSD userland — NOT GNU/Linux.** Prefer
  BSD-compatible syntax. `sed -i` needs an argument: `sed -i '' …`. Avoid
  GNU-only flags (`sed --in-place`, `date -d`, `ps --sort`). For process lists
  use `ps -Ao …` piped to `sort`/`head`, not GNU `ps` flags.
- Homebrew prefix is `/opt/homebrew`.
- Default editor is Helix (`hx`).

## Preferred tools

Reach for the modern CLI when it fits (all installed): `fd` (not `find`),
`eza` (not `ls`), `bat` (not `cat`), `rg`/`fzf`, `zoxide`, `jq`, `git-delta`,
`atuin`. `gh` for GitHub. `chezmoi` manages dotfiles.

## Installing software

Homebrew is the single source of truth. Every exception creates another
category of thing to remember — where it came from, how to update it, how to
remove it — so there are none beyond the one below.

- **CLI tools:** `brew install`. Not `npm install -g`, not `curl | bash`, not a
  language package manager's global mode.
- **Apps:** `brew install --cask`. Not `.dmg`, not the App Store.
- **Language runtimes and per-project tooling:** the exception. `mise` for
  runtimes, `uv` for Python. Projects pin their own versions, so these must stay
  isolated rather than system-wide — a global upgrade breaking an unrelated
  project is exactly what this avoids.

The payoff is that `brew list` is a complete inventory and `brew uninstall`
is a complete removal. Vendor installers (AWS, Docker, cloud CLIs) usually have
a formula or cask — check `brew info <name>` before reaching for their own
installer, and check availability rather than `brew list`, which only shows what
is already installed.

Reasoning: <https://orlovsky.dev/blog/brew>

## Working style

- Be terse and direct. Lead with the answer; skip preamble and filler.
- Reply in the language I'm using (English or Russian).
- Confirm before outward-facing or hard-to-reverse actions (git push, deploys,
  publishing). Don't push unless asked.
- When something is done and verified, say so plainly; if a step failed or was
  skipped, say that too — no glossing.
