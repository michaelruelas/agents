---
name: pup
description: "Use when working with Datadog observability via CLI. Covers metrics, logs, traces, monitors, dashboards, SLOs, incidents, RUM, synthetics, security, costs, CI visibility, and 30+ other Datadog API domains. Replaces Datadog MCP with stateless CLI commands."
---

# Pup — Datadog CLI

Pup CLI installed via Homebrew (`brew install datadog-labs/pack/pup`). 200+ commands across 33+ Datadog products.

## Auth

```bash
# OAuth2 (preferred)
pup auth login
pup auth status
pup auth refresh
pup auth logout

# API keys (fallback)
export DD_API_KEY=xxx
export DD_APP_KEY=xxx
export DD_SITE=datadoghq.com

# Bearer token (headless)
export DD_ACCESS_TOKEN=xxx
```

Auth priority: `DD_ACCESS_TOKEN` > OAuth2 tokens > `DD_API_KEY` + `DD_APP_KEY`.

## Metrics

```bash
pup metrics query --query="avg:system.cpu.user{*}" --from=1h
pup metrics search --query="avg:system.cpu.user{*}" --from=1h
pup metrics list --filter="system.*"
pup metrics get <metric_name>
```

## Logs

```bash
pup logs search --query="status:error" --from=1h --limit=20
pup logs search --query="service:web-app" --from="2024-01-01T00:00:00Z"
pup logs list --query="status:error" --from=1h --limit=100
pup logs aggregate --query="status:error" --from=1h --compute="count" --group-by="service"
```

Time ranges: `5s`, `30m`, `1h`, `4h`, `1d`, `7d`, `30d`, or RFC3339 timestamps.

## Monitors

```bash
pup monitors list
pup monitors list --tags="env:prod,team:api"
pup monitors list --limit=500
pup monitors search --query="status:Alert"
pup monitors get <id>
pup monitors delete <id> --yes
```

## Traces & APM

```bash
pup traces search --query="service:web-app @duration:>5000000000" --from=1h
pup traces aggregate --query="service:web-app" --from=1h
pup traces metrics list
pup apm services list
pup apm entities list
pup apm dependencies --service=web-app --from=1h
pup apm flow-map --service=web-app
```

**APM durations are in nanoseconds**: 1s = 1000000000, 5ms = 5000000.

## Dashboards

```bash
pup dashboards list
pup dashboards get <id>
pup dashboards url <id> --from=now-1w --to=now --live=true
pup dashboards delete <id> --yes
```

## SLOs

```bash
pup slos list
pup slos get <id>
pup slos status <id> --from=1h
pup slos delete <id> --yes
```

## Incidents

```bash
pup incidents list
pup incidents get <id>
pup incidents attachments list <id>
pup incidents settings list
pup incidents handles list
pup incidents postmortem-templates list
```

## RUM

```bash
pup rum apps list
pup rum sessions search --query="service:web-app" --from=1h
pup rum metrics query --query="*" --from=1h
pup rum retention-filters list
pup rum playlists list
pup rum heatmaps query --from=1h
```

## Synthetics

```bash
pup synthetics tests list
pup synthetics locations list
pup synthetics suites list
```

## Security

```bash
pup security rules list
pup security signals list --query="status:critical" --from=1d
pup security findings list --from=1d
pup security findings analyze --query="SELECT * FROM findings" --from=7d
pup security content-packs list
pup security risk-scores list
```

## Events

```bash
pup events list --from=1h
pup events search --query="sources:pagerduty status:error" --from=1h
pup events get <id>
```

## Infrastructure

```bash
pup infrastructure hosts list
pup infrastructure hosts get <hostname>
pup containers list
pup containers images list
pup processes list
```

## Tags

```bash
pup tags list
pup tags get <hostname>
pup tags add <hostname> --tags="env:prod,team:api"
pup tags update <hostname> --tags="env:prod,team:backend"
pup tags delete <hostname> --tags="env:prod"
```

## Integrations

```bash
pup integrations slack list
pup integrations pagerduty list
pup integrations webhooks list
pup integrations jira list
pup integrations servicenow list
```

## CI/CD

```bash
pup cicd pipelines list --from=1h
pup cicd events list --from=1h
pup cicd tests list --from=1h
pup cicd flaky-tests list --from=7d
pup cicd dora deployments list --from=30d
```

## Users & Org

```bash
pup users list
pup users get <id>
pup users roles list <id>
pup users seats list
pup organizations get
pup organizations list
```

## API keys & App keys

```bash
pup api-keys list
pup api-keys get <id>
pup api-keys create --name "my-key"
pup api-keys delete <id>
pup app-keys list
pup app-keys create --name "my-app-key"
pup app-keys delete <id>
```

## Cost & Usage

```bash
pup usage summary --from=30d
pup usage hourly --from=1d
pup costs datadog projected
pup costs datadog attribution --start 2024-01 --fields team,service
pup costs datadog by-org --start-month 2024-01
```

## Cases & Workflows

```bash
pup cases list
pup cases create --title "Incident follow-up" --priority P2
pup cases search --query="status:open"
pup workflows list
pup workflows get <id>
pup workflows run <id>
pup workflows instances list <id>
```

## Network

```bash
pup network flows list --from=1h
pup network devices list
pup network interfaces list
```

## Error Tracking

```bash
pup error-tracking issues search --query="service:web-app" --from=1h
pup error-tracking issues get <id>
```

## Service Catalog

```bash
pup service-catalog list
pup service-catalog get <id>
pup scorecards list
pup scorecards get <id>
```

## Downtimes

```bash
pup downtime list
pup downtime get <id>
pup downtime cancel <id>
```

## Workflows

```bash
pup workflows list
pup workflows get <id>
pup workflows create --file workflow.json
pup workflows run <id>
pup workflows instances list <id>
pup workflows instances get <id>
```

## Runbooks

```bash
pup runbooks list
pup runbooks describe <name>
pup runbooks run <name> --arg SERVICE=payments
pup runbooks run <name> --dry-run
pup runbooks import ./my-runbook.yaml
pup runbooks validate ./my-runbook.yaml
```

## Output format

Default: JSON. Use `--output=table`, `yaml`, or `csv` for human-readable:

```bash
pup monitors list --output=table
pup logs search --query="status:error" --from=1h --output=table
```

## Global flags

| Flag | Purpose |
|------|---------|
| `--output json\|table\|yaml\|csv` | Output format (default: json) |
| `--yes` | Skip confirmation prompts |
| `--org <name>` | Named org session (multi-org) |
| `--agent` | Enable agent mode (auto-detected in AI tools) |

## Script authoring

When writing scripts for the user, append `--no-agent` so output format matches what they'd see outside the agent session:

```bash
pup --no-agent monitors list | jq '.[].name'
```

## Gotchas

- APM durations are in **nanoseconds** — 1s = 1000000000
- Always specify `--from` on time-series queries (default is 1h but be explicit)
- Use `--tags` to filter monitors/list calls instead of fetching all and parsing locally
- `logs aggregate` is cheaper/faster than fetching all logs and counting locally
- Deleting resources (`monitors delete`, `dashboards delete`, etc.) requires `--yes` for non-interactive use
- Auth priority: `DD_ACCESS_TOKEN` > OAuth2 (`pup auth login`) > `DD_API_KEY` + `DD_APP_KEY`
- For large orgs, always filter with `--limit` and `--tags`/`--query` before listing all
- `pup logs search` returns raw log events; `pup logs aggregate` returns computed counts
- Time ranges accept relative (`1h`, `7d`, `30m`) and absolute (RFC3339, Unix ms) formats
- `metrics query` requires an aggregation function (`avg:`, `sum:`, `max:`, `min:`, `count:`)
- `pup auth login` stores tokens in macOS Keychain by default; use `DD_TOKEN_STORAGE=file` for plaintext
- Multi-org: `pup auth login --org staging-child`, then `pup monitors list --org staging-child`