# AGENTS.md — guide for working on this repo

This file is for any agent (human or AI) editing, adding, or syncing skills in `~/.agents/`. Read it before making changes.

## What this repo is

Canonical source for agent skills deployed across `opencode`, `claude`, and `hermes`. The repo holds the **real** files; consumer locations (`~/.config/opencode/skills/`, `~/.claude/skills/`, `~/.hermes/skills/`) hold **symlinks** that point back here. Edit here, then sync.

## Layout

```
~/.agents/
  AGENTS.md              # this file
  README.md              # inventory + deploy guide (for humans)
  .skill-lock.json       # contentSha of agentskill.sh/* installs
  scripts/
    sync.sh              # idempotent symlink deployer
  skills/
    <skill-name>/
      SKILL.md           # required: name + description frontmatter + body
      references/        # optional: supporting docs
      agents/            # optional: sub-agent definitions
      README.md          # optional: only when SKILL.md is insufficient
      LICENSE            # optional
```

## Conventions for every skill

- **Folder name MUST equal `name:` field** in `SKILL.md` frontmatter. If they differ, rename the folder (don't rename the field).
- **SKILL.md is required** with YAML frontmatter:
  - `name:` — single short token (lowercase, hyphenated)
  - `description:` — when to use this skill, written for agent auto-discovery. Use `>-` (folded scalar) for multi-line.
- **No SKILL.md body section is required**, but most skills benefit from: install instructions, usage examples, output schema.
- **Avoid `orca`/`swarm`** in skill content — user no longer uses those tools.

## Adding a skill

1. Create `skills/<name>/SKILL.md` with frontmatter + body.
2. Optionally add `references/`, `agents/`, `LICENSE`.
3. Commit + push to `main`.
4. Run `./scripts/sync.sh` to deploy symlinks at all consumers.
5. Run `./scripts/sync.sh status` first to preview changes.

## Editing a skill

1. Edit files under `skills/<name>/`.
2. Commit + push.
3. Re-run `./scripts/sync.sh` (usually a no-op since symlinks already point here; only needed if you renamed folders).

## Removing a skill

1. `rm -rf skills/<name>/`.
2. Commit + push.
3. `./scripts/sync.sh` will remove stale symlinks at consumers automatically.

## Skill provenance

When editing, respect the source-of-truth rule:

| Provenance | Source repo | Edit here, then… |
|---|---|---|
| Manual | this repo | edit directly, commit |
| `agentskill.sh/*` | upstream agentskill.sh | re-pull via `npx @agentskill.sh/cli setup` if upstream changed; or edit locally + bump `contentSha` in `.skill-lock.json` |
| GitHub deploy (e.g. `pr-review`) | the GitHub repo (e.g. `michaelruelas/pr-reviewer`) | edit in the source repo, then re-copy: `cp -R ~/code/<repo>/<dir> skills/<name>` |

## `.skill-lock.json`

Tracks `contentSha` (first 7 chars of SHA-1 of `SKILL.md`) for `agentskill-sh/*` installs. Purpose: re-running `npx @agentskill.sh/cli setup` can detect whether upstream changed and decide whether to overwrite.

**When to update manually:** after editing an `agentskill-sh/*` skill locally and committing. Compute new SHA:

```bash
shasum -a 1 skills/learn/SKILL.md | awk '{print substr($1,1,7)}'
```

Then edit `.skill-lock.json` and update the `contentSha` field. Also bump `installedAt` to the current ISO timestamp.

## Deploy / sync

**Always run `./scripts/sync.sh status` before `./scripts/sync.sh`** to preview.

```bash
cd ~/.agents
./scripts/sync.sh status    # dry-run
./scripts/sync.sh           # apply
```

What the script does:
- For each folder in `skills/`, ensure a symlink exists at every consumer pointing back here.
- Replace mismatched symlinks (different target path).
- Remove stale symlinks whose target is inside `skills/` but no longer matches a folder here.
- Leave unrelated symlinks alone (checks target path is inside our skills dir).
- Skip (warn) if a real file/dir exists where a symlink should go.

**Default consumers** (overridable via `AGENTS_CONSUMERS="label:path ..."`):
- `opencode` → `~/.config/opencode/skills/`
- `claude` → `~/.claude/skills/`
- `hermes` → `~/.hermes/skills/`

**On a new machine:**
```bash
git clone git@github.com:michaelruelas/agents.git ~/.agents
ln -sf ~/.agents/scripts/sync.sh ~/.local/bin/agents
agents sync
```

## Common pitfalls

- **Editing files in consumer locations instead of `~/.agents/skills/`** — those are symlinks, your changes appear to work but get clobbered on next sync. Always edit in the repo.
- **Renaming a skill folder without renaming `name:` field** (or vice versa) — breaks discovery. Keep them in sync.
- **Adding skills to consumer directories manually** — sync will see them as unrelated and won't touch them. Add them to `~/.agents/skills/` instead.
- **Forgetting `scripts/sync.sh` after a rename** — old symlinks will stay until next sync. Always sync after structural changes.
- **Committing `.skill-lock.json` with stale `contentSha`** — future `npx @agentskill.sh/cli setup` runs may think upstream changed and clobber your local edits.

## Verification checklist after any change

```bash
./scripts/sync.sh status   # should be 0 changes (or only the changes you made)
ls -la ~/.config/opencode/skills/<name> ~/.claude/skills/<name> ~/.hermes/skills/<name>
# all three should be symlinks pointing to ~/.agents/skills/<name>
```
