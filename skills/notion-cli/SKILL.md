---
name: notion-cli
description: "Use when working with Notion workspaces, pages, databases/data sources, files, comments, or Notion Workers via CLI. Covers authentication, API requests with HTTPie-style inline syntax, data source queries, page Markdown CRUD, file uploads, worker scaffolding/deploy/exec, and diagnostics. Replaces Notion MCP with stateless CLI commands."
---

# Notion CLI

`ntn` is the official Notion CLI. Use it for auth, raw API calls, data source queries, Markdown-based page CRUD, file uploads, and Notion Workers.

## Install

```bash
curl -fsSL https://ntn.dev | bash       # macOS/Linux (recommended)
npm install -g ntn                       # Node 22+, npm 10+
winget install Notion.ntn                # Windows x64
ntn --version
ntn completions zsh                      # shell completions
```

## Auth

```bash
ntn login                                # browser flow -> OS keychain
ntn login --no-browser                   # headless / CI / remote (prints URL + code)
ntn logout                               # clear stored credentials

# PAT for scripts/CI (beats keychain when set)
export NOTION_API_TOKEN=ntn_xxx...

# Target a non-default workspace for one command
NOTION_WORKSPACE_ID=<id> ntn api v1/users/me

# Force file-based auth in containers / SSH / no-keychain envs
NOTION_KEYRING=0 ntn login               # writes ~/.config/notion/auth.json

# Verify
ntn doctor
```

## Global flags & env

| Flag / Var | Purpose |
|---|---|
| `-v, --verbose` | Full req/res dump on stderr (Authorization redacted) |
| `--notion-version` / `NOTION_API_VERSION` | Pin Notion-Version header |
| `NOTION_API_TOKEN` | PAT override (beats keychain) |
| `NOTION_WORKSPACE_ID` | Skip workspace picker |
| `NOTION_KEYRING=0` | Use `auth.json` instead of OS keychain |
| `--json` / `--plain` | Script-friendly output (most commands) |

## API requests — `ntn api`

The workhorse. HTTPie-style inline syntax for any Notion endpoint.

### Read

```bash
ntn api v1/users/me
ntn api "v1/pages/$PAGE_ID"
ntn api "v1/blocks/$PAGE_ID/children"
ntn api v1/search query=roadmap page_size:=10
```

### Write — inline body fields

```bash
# POST (default when any body input is present)
ntn api v1/pages \
  parent[page_id]="$PARENT" \
  properties[Name][title][0][text][content]="New page"

# PATCH / DELETE
ntn api "v1/pages/$PAGE_ID" -X PATCH archived:=true
ntn api "v1/pages/$PAGE_ID" -X DELETE

# Complex field as inline JSON
ntn api v1/data_sources \
  parent[type]=database_id \
  parent[database_id]="$DB" \
  title[0][type]=text title[0][text][content]="Bugs" \
  properties:='{"Name":{"title":{}},"Status":{"select":{"options":[{"name":"Open"}]}}}'
```

### Body syntax

| Form | Use | Example |
|---|---|---|
| `path=value` | string field | `parent[page_id]=abc` |
| `path:=json` | typed (bool/num/null/array/object) | `archived:=true`, `page_size:=10` |
| `name==value` | query param | `page_size==100` |
| `Header:Value` | request header | `X-Trace-Id:cli-1` |

Prefer bracket notation for keys with spaces or punctuation:

```bash
properties[Build version][rich_text][0][text][content]="2026.05.11"
```

Use `[]` to append repeated values in order:

```bash
rich_text[][text][content]="line one"
rich_text[][text][content]="line two"
```

### Body from JSON / stdin

```bash
ntn api v1/pages < create-page.json
jq -n --arg p "$PARENT" '{parent:{page_id:$p},properties:{Name:{title:[{text:{content:"x"}}]}}}' \
  | ntn api v1/pages
ntn api v1/search --data '{"query":"roadmap","page_size":10}'

# Multipart file (for manual file-upload parts)
ntn api "v1/file_uploads/$ID/send" --file ./chunk.bin part_number=1
```

### Inspect before calling

```bash
ntn api ls                                # all public endpoints
ntn api ls --json
ntn api v1/comments --help                # live endpoint help
ntn api v1/comments --spec -X POST        # OpenAPI fragment
ntn api v1/comments --docs -X POST        # markdown reference page
```

### Debug

```bash
ntn --verbose api "v1/pages/$PAGE_ID"     # method, URL, headers, body, status, x-request-id
```

`Authorization` is redacted by default. `--unsafe-verbose` disables redaction (do not paste its output anywhere).

## Data sources

```bash
# DB id -> data source ids (Notion's two-level model)
ntn datasources resolve <database-id>

# Retrieve schema
ntn api "v1/data_sources/$ID"

# Query pages
ntn datasources query "$ID" --limit 50
ntn datasources query "$ID" \
  --filter '{"property":"Status","select":{"equals":"Open"}}'
ntn datasources query "$ID" --json | jq '.results[].id'

# Paginate (cursor from `next_cursor`)
ntn datasources query "$ID" --start-cursor "$NEXT"

# Sort + multi-clause filter -> drop to `ntn api`
ntn api "v1/data_sources/$ID/query" \
  filter:='{"and":[{"property":"Status","select":{"equals":"Open"}},{"property":"Priority","number":{"greater_than_or_equal_to":2}}]}' \
  sorts:='[{"property":"Priority","direction":"descending"}]'

# Restrict returned columns (faster on wide schemas)
ntn api 'v1/data_sources/$ID/query?filter_properties[]=title&filter_properties[]=Status'

# Create / update schema
ntn api v1/data_sources -X POST \
  parent[type]=database_id parent[database_id]="$DB" \
  title[0][type]=text title[0][text][content]="Bugs" \
  properties:='{"Name":{"title":{}},"Status":{"select":{"options":[{"name":"Open"}]}}}'
ntn api "v1/data_sources/$ID" -X PATCH \
  properties:='{"Assignee":{"people":{}}}'

# List page templates
ntn api "v1/data_sources/$ID/templates"
```

## Pages (Markdown workflow)

Fastest path to read/write page content.

```bash
# Read as Markdown
ntn pages get <page-id>
ntn pages get <page-id> --json

# Create from Markdown (stdin or --content)
echo "# Hello\n\nBody text." | ntn pages create --parent page:<parent-id>
ntn pages create --parent database:<db-id> --content ./template.md
ntn pages create --parent data-source:<ds-id> --content @./seed.md

# Update content
ntn pages edit <page-id> --content ./updated.md
ntn pages edit <page-id> --content ./replace.md --allow-deleting-content

# Trash
ntn pages trash <page-id> --yes
```

Parent formats: `page:<id>`, `database:<id>`, `data-source:<id>`.

## Files

```bash
# Upload local file
FILE_ID=$(ntn files create --plain < ./photo.png | cut -f1)

# Upload with overrides (e.g. piped bytes)
generate-report --format pdf \
  | ntn files create --filename weekly.pdf --content-type application/pdf

# External URL import (async)
FILE_ID=$(ntn files create --plain \
  --external-url https://example.com/x.png --filename x.png | cut -f1)
ntn files get "$FILE_ID"                  # poll until status=uploaded

# Attach as image block
ntn api "v1/blocks/$PAGE_ID/children" -X PATCH \
  children[0][type]=image \
  children[0][image][type]=file_upload \
  children[0][image][file_upload][id]="$FILE_ID"

# Attach as generic file block
ntn api "v1/blocks/$PAGE_ID/children" -X PATCH \
  children[0][type]=file \
  children[0][file][type]=file_upload \
  children[0][file][file_upload][id]="$FILE_ID"

# Attach to a "files" property on a database page
ntn api "v1/pages/$PAGE_ID" -X PATCH \
  properties[Attachments][files][0][type]=file_upload \
  properties[Attachments][files][0][file_upload][id]="$FILE_ID" \
  properties[Attachments][files][0][name]=contract.pdf

# List / get
ntn files list
ntn files list --json
ntn files get <upload-id>
```

## Notion Workers

TypeScript programs that extend Notion with syncs, agent tools, and webhooks. Hosted by Notion.

```bash
# Scaffold + deploy
ntn workers new my-worker
cd my-worker
# edit src/index.ts -> add worker.tool / worker.sync / worker.webhook
ntn workers deploy

# Common flags for `workers` subcommands: --json / --plain / --worker-id <id>

# Inventory
ntn workers list
ntn workers list --json
ntn workers get <worker-id>
ntn workers delete <worker-id> --yes
ntn workers tui                          # interactive UI

# Run a capability (tool / sync / webhook)
ntn workers exec sayHello -d '{"name":"World"}'
ntn workers exec <key> -d @input.json
ntn workers exec <key> -d @input.json --stream
ntn workers exec <key> -d @input.json --local --dotenv .env    # run via tsx

# Syncs
ntn workers sync status                          # live updates (2s poll)
ntn workers sync status <key> --no-watch
ntn workers sync trigger <key>                   # bypass schedule
ntn workers sync trigger <key> --preview         # dry run
ntn workers sync pause <key>
ntn workers sync resume <key>
ntn workers sync state get <key>
ntn workers sync state reset <key>               # restart from scratch

# Secrets (values write-only; never returned by list)
ntn workers env set API_KEY=sk_xxx OTHER=value
ntn workers env list
ntn workers env pull                             # to .env
ntn workers env push                             # from .env
ntn workers env unset API_KEY

# OAuth
ntn workers oauth start <key>                    # opens provider URL
ntn workers oauth token <key> --plain            # debug
ntn workers oauth show-redirect-url

# Runs & logs
ntn workers runs list
ntn workers runs logs <run-id>

# Webhook URLs
ntn workers webhooks list

# Capabilities inventory
ntn workers capabilities list
```

## Diagnostics

```bash
ntn doctor                                # auth, keychain, network, config
ntn update                                # self-update (--force to reinstall)
ntn --version
ntn api ls                                 # public endpoints
```

## Gotchas

- **Body input flips default method to POST.** If you only want to read, pass `-X GET` (or omit all body sources).
- `=` is always a string. Use `:=` for `true` / `false` / numbers / `null` / arrays / objects.
- `ntn login` requires full workspace membership — guests and restricted members cannot log in; use a PAT instead.
- File uploads expire ~1 hour after creation; attach before `expiry_time` or they can't be linked.
- External URL imports are async — poll `ntn files get` until `status=uploaded` (or `failed`).
- Database IDs and data source IDs are distinct. If you only have a DB URL, run `ntn datasources resolve <db-id>` first.
- `ntn api` already sets `Authorization` and `Notion-Version` — don't pass them manually.
- Pin a version with `--notion-version 2026-03-11` (or `NOTION_API_VERSION`) when you need stable behavior.
- In Docker / CI / SSH without a usable keychain, set `NOTION_KEYRING=0` or use a PAT.
- `ntn workers exec --local` needs `tsx` installed locally and reads `.env` by default — pass `--no-dotenv` to skip.
- Query results cap at 10,000 pages — narrow with filters or subscribe to webhooks for larger data sources.

## When to use MCP instead

`ntn` covers everything the Notion MCP does, with one trade-off:
- **Realtime push streams** (live webhook deliveries, change feeds that must auto-update in the UI) — prefer the MCP or build a worker with a webhook handler.
- For everything else (read/write pages, search, query data sources, file CRUD, comments, workers), use this skill + `bash`.
