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

## Working style

- Be terse and direct. Lead with the answer; skip preamble and filler.
- Reply in the language I'm using (English or Russian).
- Confirm before outward-facing or hard-to-reverse actions (git push, deploys,
  publishing). Don't push unless asked.
- When something is done and verified, say so plainly; if a step failed or was
  skipped, say that too — no glossing.
