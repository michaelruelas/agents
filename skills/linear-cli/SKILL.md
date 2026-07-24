---
name: linear-cli
description: "Use when working with Linear issues, projects, cycles, teams, or comments via CLI. Covers creating, updating, listing, and searching issues; managing projects and sprints; and adding comments. Replaces Linear MCP with stateless CLI commands."
---

# Linear CLI

Stateless CLI for Linear. Designed as MCP replacement — JSON output, no interactive prompts, meaningful exit codes.

## Auth

```bash
export LINEAR_API_KEY=lin_api_xxxxx        # set API key
linear auth login --token <key>        # or save to config
linear auth whoami                     # verify auth
```

## Issues

```bash
# List
linear issue list --team ENG
linear issue list --team ENG --status "In Progress"
linear issue list --assignee me --priority 1
linear issue list --label bug --limit 10

# Get
linear issue get ENG-123

# Create
linear issue create --title "Fix login bug" --team ENG
linear issue create --title "Big task" --team ENG --priority 1 --label bug
linear issue create --title "Sprint task" --team ENG --cycle <id> --assignee <user_id>
linear issue create --title "Refactor" --team ENG --description-file ./desc.md

# Update
linear issue update ENG-123 --status "In Done"
linear issue update ENG-123 --assignee <user_id>
linear issue update ENG-123 --priority 2
linear issue update ENG-123 --label "in-review"

# Search
linear issue search "login bug" --team ENG
```

## Projects

```bash
linear project list
linear project get <project_id>
linear project create --name "Q3 Roadmap" --team ENG
linear project update <project_id> --name "Q3 Roadmap v2"
```

## Cycles (sprints)

```bash
linear cycle list --team ENG
linear cycle get <cycle_id>
```

## Comments

```bash
linear comment list --issue ENG-123
linear comment create --issue ENG-123 --body "Looking into this"
linear comment create --issue ENG-123 --body-file ./update.md
```

## Teams & users

```bash
linear team list
linear user list
linear user list --team ENG
```

## Labels

```bash
linear label list
```

## Workflow states

```bash
linear status list --team ENG
```

## Config

```bash
linear config show                     # current config
linear config set default_team ENG     # set default team
```

## Output

All commands return JSON by default. Add `--pretty` for formatted output:

```bash
linear issue get ENG-123 --pretty
```

## Exit codes

| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Invalid arguments |
| 3 | Authentication error |
| 4 | Resource not found |
| 5 | Rate limit exceeded |
| 6 | Network error |
| 7 | Permission denied |

## Pagination

Use cursor-based pagination for large result sets:

```bash
linear issue list --team ENG --limit 50 --cursor "abc123"
```

## Gotchas

- `--label` accepts label name, not ID — resolved automatically
- `--assignee` accepts user ID or `"me"` for current user
- Priority integers: 0=None, 1=Urgent, 2=High, 3=Medium, 4=Low
- `--description-file` preferred over `--description` for multi-line markdown
- No `--pretty` = raw JSON output (good for piping)
- Auth via `LINEAR_API_KEY` env var or `linear auth login`
