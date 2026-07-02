# skills/

Canonical version of every skill deployed across agent platforms.

## Rules

- **One folder per skill.** Folder name must equal the `name:` field in the SKILL.md frontmatter.
- **SKILL.md is required.** It must have `name:` and `description:` YAML frontmatter so agents can auto-discover it.
- **Use `references/` for supporting docs** that aren't needed for skill activation but support implementation (e.g. style guides, detailed references).
- **Use `agents/` for sub-agent definitions** that the skill spawns (e.g. multi-lens reviews).
- **Add a README.md only when SKILL.md isn't enough.** SKILL.md is the canonical per-skill doc; README.md is for repo-level context that doesn't belong on the skill itself.

## Adding a new skill

```
skills/<name>/
  SKILL.md
```

Then commit, push, and re-run the deploy loop in the root README.

## Deploy

Every folder here is symlinked (not copied) into:

- `~/.config/opencode/skills/<name>`
- `~/.claude/skills/<name>`

The symlinks break if this folder is renamed or moved. Keep paths stable.
