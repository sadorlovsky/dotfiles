---
name: disable-telemetry
description: Find and disable telemetry, usage analytics and crash reporting in software installed on this Mac, and grow the telemetry-off opt-out database. Use when asked to disable/opt out of telemetry or tracking, audit what phones home, after installing new software, or when the telemetry-off hook or a notification reports software "with no known telemetry opt-out". Also for /disable-telemetry with an optional app or package name.
---

# disable-telemetry

The machinery is `~/.config/telemetry-off/telemetry-off` (zsh) with its database
`optouts.json` beside it. Both are **chezmoi-managed**: never edit the files in
`~/.config/telemetry-off/` — edit the source copy and apply:

```sh
DB="$(chezmoi source-path)/dot_config/telemetry-off/optouts.json"
# …edit $DB…
chezmoi apply ~/.config/telemetry-off
```

Automatic side (already running, don't rebuild it): a launchd agent
(`com.github.sadorlovsky.telemetry-off`, WatchPaths on Cellar / Caskroom /
/Applications / uv / mise) and a Claude Code PostToolUse hook both run
`telemetry-off watch`, which applies known opt-outs to newly installed software
and queues the rest as *pending*. This skill is the research side: it turns
pending/unknown items into database entries.

## Workflow

1. **Inventory.** `~/.config/telemetry-off/telemetry-off scan` → one row per
   installed item: `known` (has entry), `none` (listed as no telemetry),
   `unknown`. `--json` for structured output. `… pending` lists unknowns the
   watcher queued. If the user named a specific package/app, work on just that.

   The scan covers Homebrew formulae installed on request, casks, non-Apple apps
   in /Applications not owned by a cask, mise tools, uv tools, npm and bun
   globals. It does **not** cover editor extensions, browser extensions, or
   per-project dependencies — mention that if the user asks for "everything".

2. **Research each unknown.** Batch them; for more than ~8, fan out to
   subagents (CLI tools vs GUI apps) and have each return entries in the schema
   below. Sources, in order of trust: official docs / admin & enterprise
   deployment guides (they document `defaults` keys and policy files) → the
   source code → maintainers in the issue tracker → anything else. Look for:
   - an env var (`FOO_TELEMETRY_DISABLED`, `DO_NOT_TRACK` support);
   - a persistent CLI command (`tool telemetry disable`, `tool config set …`);
   - a `defaults` key for the app's bundle id (confirm with `defaults read`);
   - a config-file key (JSON → `json` action; TOML/YAML/JSONC → `cmd` or `manual`);
   - a GUI-only toggle (→ `manual`, with the exact menu path).

   **Never invent a key or flag.** If no source confirms it, use a `manual`
   action or leave the item unknown and say so. A tool with genuinely no
   telemetry goes into `no_telemetry` — only when the docs/source support that,
   not because nothing turned up.

3. **Write entries** into the source `optouts.json` (keep `tools` keys sorted;
   keep the file valid — check with `jq -e . "$DB"`). Then
   `chezmoi apply ~/.config/telemetry-off`.

4. **Apply.** `~/.config/telemetry-off/telemetry-off apply <id>…` (no args =
   every installed known entry). Env actions take effect in new shells only —
   say so. For `defaults` actions on a running app, ask the user to quit it
   first or it may overwrite the change on quit. Re-run `scan` to confirm the
   items moved to `known`/`none`.

5. **Report**: what was applied, which steps are manual (give the exact UI
   path), what stayed unknown and why. The database change is an uncommitted
   edit in the chezmoi repo (a public GitHub repo) — offer to commit; don't push
   unless asked.

## Database schema (`optouts.json`)

```json
{
  "no_telemetry": ["bat", "ripgrep", "com.example.app"],
  "tools": {
    "<id>": {
      "match":  { "formula": [], "cask": [], "app": ["<bundle id>"], "mise": [], "uv": [], "npm": [], "bun": [] },
      "always": false,
      "actions": [
        { "type": "env",      "name": "FOO_TELEMETRY_DISABLED", "value": "1" },
        { "type": "cmd",      "run": "foo telemetry disable", "check": "foo telemetry status | grep -q disabled" },
        { "type": "defaults", "domain": "com.example.app", "key": "SendAnalytics", "kind": "bool", "value": false },
        { "type": "json",     "file": "~/.config/foo/settings.json", "path": ["telemetry", "enabled"], "value": false },
        { "type": "manual",   "text": "Settings → Privacy → turn off \"Share usage data\"" }
      ],
      "source": "https://…",
      "note": "one line: what it collects / caveats",
      "verified": "YYYY-MM-DD"
    }
  }
}
```

- `match` lists the inventory names (formula/cask token, app **bundle id**,
  package name) that this entry covers; one entry typically lists both the cask
  and the bundle id. Omit `match` and the entry matches any kind by its `id`.
  `always: true` applies it on every `apply --all` regardless of inventory
  (Homebrew itself).
- `env` actions from *every* entry are compiled into
  `~/.local/state/telemetry-off/env.zsh`, sourced by `rc.d/15-privacy.zsh`.
  Variables already exported in `15-privacy.zsh` needn't be repeated.
- `cmd` runs under `zsh -c` with Homebrew on PATH; it must be idempotent. Give
  a `check` when there's a cheap way to tell it's already off.
- `json` refuses JSONC files (comments) and turns into a manual note.
- Prefer persistent mechanisms (config, command) over env vars for tools that
  are also launched outside a shell (GUI-launched, launchd, IDE).

## Exceptions the user made on purpose

- **Claude Code**: `rc.d/85-functions.zsh` unsets `DO_NOT_TRACK` for the
  `claude` process because it breaks the feature-flag evaluation Remote Control
  needs. Don't add opt-outs for Claude Code that would do the same
  (e.g. `CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`) without asking.

## State & debugging

`~/.local/state/telemetry-off/`: `log.tsv` (every applied/failed/manual/unknown
event), `pending.tsv`, `seen.tsv` (delete to re-baseline), `env.zsh`,
`backup/` (original copy of each JSON file before the first edit),
`launchd.log`. `telemetry-off recent 3600` shows the last hour of the log.
