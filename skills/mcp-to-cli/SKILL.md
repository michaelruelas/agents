---
name: mcp-to-cli
description: Convert MCP tools into CLI-based skills to reduce token usage. Use when you have an MCP server that injects tool schemas into every message, and want to replace it with a lightweight CLI tool + skill reference that loads only when needed.
---

# MCP-to-CLI Conversion

## Why

MCP tool schemas are injected into every message. A 20-tool MCP adds ~2-5k tokens per message. A skill loads once, stays in context only when invoked.

**Token savings:**
- MCP: tool schemas × every message = constant tax
- CLI skill: ~500 tokens (skill description) + ~1-2k (loaded reference) = one-time cost

## The pattern

```
MCP server → CLI tool + SKILL.md reference
```

## Conversion steps

### 1. Audit the MCP

List every tool the MCP exposes. For each, note:
- What it does (read/write/admin)
- What CLI equivalent exists
- What flags/args it takes

```bash
# Example: list MCP tools
# Check your opencode.json or MCP config for tool names
```

### 2. Find the CLI tool

Most MCPs have official CLI equivalents:

| MCP | CLI | Install |
|-----|-----|---------|
| ArgoCD | `argocd` | `brew install argocd` |
| Kubernetes | `kubectl` | `brew install kubectl` |
| Tailscale | `tailscale` | App store or `brew install tailscale` |
| Linear | `linear` | (check Linear docs) |
| GitHub | `gh` | `brew install gh` |
| Cloudflare | `wrangler` | `npm install -g wrangler` |
| Supabase | `supabase` | `brew install supabase` |
| Vercel | `vercel` | `npm install -g vercel` |
| Terraform | `terraform` | `brew install terraform` |

### 3. Create the skill directory

```
.opencode/skills/<tool-name>/
├── SKILL.md          # Main reference (loaded on invoke)
└── references/       # Optional: detailed subreferences
    ├── basic.md
    ├── advanced.md
    └── examples.md
```

### 4. Write SKILL.md

Follow this template:

```markdown
---
name: <tool-name>
description: "<one-line: when to use this skill>"
---

# <Tool Name>

## What you have

<CLI tool> is installed and available. Use it via `bash` tool calls.

## Quick reference

### <Category 1>

```bash
<command> --help
<command> <subcommand> [args]
```

### <Category 2>

```bash
<command> <subcommand> [args]
```

## Common patterns

### Pattern 1: <description>

```bash
<command> <flags>
```

### Pattern 2: <description>

```bash
<command> <flags>
```

## Gotchas

- <Gotcha 1>
- <Gotcha 2>

## When to use MCP instead

<Note any cases where the MCP is still better, e.g. real-time watches, complex queries>
```

### 5. Test the conversion

1. Remove (or comment out) the MCP from your config
2. Load the skill: `skill(name="<tool-name>")`
3. Run the CLI commands via `bash`
4. Verify you can do everything the MCP did

### 6. Remove the MCP

Once verified, remove the MCP server from your config:
- `opencode.json` → remove from `mcp` section
- Or Settings → Extensions → remove the MCP

## Quality checklist

- [ ] Every MCP tool has a CLI equivalent documented
- [ ] SKILL.md loads in <1k tokens (keep it concise)
- [ ] Subreferences only loaded when needed
- [ ] Common patterns include real command examples
- [ ] Gotchas section captures non-obvious behavior
- [ ] Tested: removed MCP, skill covers all use cases

## Example conversions

### ArgoCD MCP → `argocd` CLI

MCP tools → CLI commands:
- `argocd_app_list` → `argocd app list -o json`
- `argocd_app_get` → `argocd app get <name>`
- `argocd_app_sync` → `argocd app sync <name>`
- `argocd_app_rollback` → `argocd app rollback <name> <revision>`
- `argocd_project_list` → `argocd proj list`

### Tailscale MCP → `tailscale` CLI

MCP tools → CLI commands:
- `tailscale_status` → `tailscale status --json`
- `tailscale_devices` → `tailscale status`
- `tailscale_ping` → `tailscale ping <hostname>`
- `tailscale_dns` → `tailscale dns status`

## Anti-patterns

**Don't:**
- Put full man pages in SKILL.md (use references/ for that)
- Copy-paste CLI help output verbatim (distill it)
- Skip the "when to use MCP instead" section (some MCPs are still better)

**Do:**
- Keep SKILL.md under 1k tokens
- Use conditional reference loading (only load what's needed)
- Include real command examples, not just syntax
- Document environment variables and auth setup
