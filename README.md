# ~/.agents — canonical skills repo

Source of truth for skills installed across `opencode`, `claude`, and `hermes`.

## Layout

```
skills/
  <skill-name>/
    SKILL.md           # required, with `name:` + `description:` frontmatter
    references/        # optional supporting docs
    agents/            # optional sub-agent definitions
```

## Deploy

Each skill in `skills/` is symlinked into both consumers:

```bash
# from this repo root
for s in skills/*/; do
  name=$(basename "$s")
  ln -sf "$PWD/$s" ~/.config/opencode/skills/"$name"
  ln -sf "../../agents/skills/$name" ~/.claude/skills/"$name"
done
```

Existing symlinks in `~/.claude/skills/` are kept; add new ones for any skills that don't already have an entry.

## Skill provenance

| Skill | Origin |
|---|---|
| `pr-review/` | Deploy copy of [michaelruelas/pr-reviewer](https://github.com/michaelruelas/pr-reviewer). Edit there, then re-copy. |
| `learn/`, `review-skill/` | Installed via `npx @agentskill.sh/cli setup`. `contentSha` tracked in `.skill-lock.json`. |
| Others | Manual installs. |

## Adding a skill

1. Drop a folder under `skills/` with a `SKILL.md` (frontmatter: `name:`, `description:`).
2. Commit + push.
3. Re-run the deploy loop above (or manually symlink one entry).
4. Restart opencode / claude session.

## `.skill-lock.json`

Tracks `contentSha` of `agentskill-sh/*` installs so re-running `npx @agentskill.sh/cli setup` knows whether to overwrite. Update the hash manually if you edit those skills locally and want to keep your edits.
