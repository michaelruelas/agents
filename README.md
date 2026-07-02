# ~/.agents — canonical skills repo

Source of truth for skills installed across `opencode`, `claude`, and other agent platforms.

## Inventory

12 skills. All deployed via symlinks to consumers.

| Skill | Description | Origin | Size |
|-------|-------------|--------|------|
| `adhd/` | Parallel divergent ideation for coding agents. 5+ cognitive frames, isolates branches, separates generator/critic phases. | Manual | 16K |
| `architecture-patterns/` | Clean/Hexagonal/Onion architecture + DDD for backend service design. | Manual | 36K |
| `attach-review-to-pr/` | Add line-specific review comments to PRs via `gh` API. | Manual | 16K |
| `code-review-excellence/` | Master code-review practices for constructive feedback. | Manual | 16K |
| `find-docs/` | Retrieve up-to-date docs for any library/framework/SDK. | Manual | 8K |
| `find-skills/` | Discover and install skills from open agent skills ecosystem. | Manual | 8K |
| `gnhf/` | GNHF agent orchestrator: prepares and steers multi-hour coding runs. | Manual (folder renamed from `hfgn/`) | 8K |
| `handoff/` | Compact current conversation into a handoff doc for another agent. | Manual | 4K |
| `learn/` | Find and install skills from agentskill.sh. CLI: `npx @agentskill.sh/cli`. | agentskill.sh (refreshed 2026-07) | 36K |
| `pr-review/` | Multi-lens PR review using 5 sub-agents (code-quality, design-pattern, error-handling, readability, solid). | Deploy copy of [michaelruelas/pr-reviewer](https://github.com/michaelruelas/pr-reviewer) | 68K |
| `review-skill/` | Audit/improve SKILL.md files against Agent Skills spec. 10-dimension quality score. | agentskill.sh (refreshed 2026-07) | 20K |
| `typescript-advanced-types/` | Master generics, conditional types, mapped types, template literals. | Manual | 20K |

## Skill provenance

| Source type | Skills |
|-------------|--------|
| Manual installs | adhd, architecture-patterns, attach-review-to-pr, code-review-excellence, find-docs, find-skills, gnhf, handoff, typescript-advanced-types |
| agentskill.sh (`.skill-lock.json`) | learn, review-skill |
| GitHub repo (deploy copy) | pr-review |

## Deploy

Use the `scripts/sync.sh` symlink deployer. Idempotent: safe to re-run after every pull.

```bash
./scripts/sync.sh           # add missing, fix mismatched, remove stale — at all consumers
./scripts/sync.sh status    # dry-run, show what would change
```

Default consumers are `opencode` (`~/.config/opencode/skills/`), `claude` (`~/.claude/skills/`), and `hermes` (`~/.hermes/skills/`). Override with `AGENTS_CONSUMERS`:

```bash
AGENTS_CONSUMERS="claude:~/.claude/skills opencode:~/.config/opencode/skills" ./scripts/sync.sh
```

To invoke as `agents sync` from anywhere, symlink the script into your `PATH`:

```bash
ln -sf ~/.agents/scripts/sync.sh ~/.local/bin/agents
```

### Manual one-liner (legacy, no idempotency)

If you don't want to use the script:

```bash
# from this repo root
for s in skills/*/; do
  name=$(basename "$s")
  ln -sf "$PWD/$s" ~/.config/opencode/skills/"$name"
  ln -sf "../../agents/skills/$name" ~/.claude/skills/"$name"
done
```

## Folder convention

Each skill lives in its own folder under `skills/<name>/`:

```
skills/<name>/
  SKILL.md           # required: name + description frontmatter + body
  references/        # optional: supporting docs
  agents/            # optional: sub-agent definitions
  README.md          # optional: only if extra context beyond SKILL.md
  LICENSE            # optional
```

Folder name should match the `name:` field in SKILL.md frontmatter. If a folder doesn't match, rename it (see git history for the `hfgn` → `gnhf` rename).

## Adding a skill

1. Drop a folder under `skills/` with a `SKILL.md` (frontmatter: `name:`, `description:`).
2. Commit + push.
3. Re-run the deploy loop above (or manually symlink one entry).
4. Restart opencode / claude session.

## `.skill-lock.json`

Tracks `contentSha` of `agentskill-sh/*` installs so re-running `npx @agentskill.sh/cli setup` knows whether to overwrite. Update the hash manually if you edit those skills locally and want to keep your edits.
