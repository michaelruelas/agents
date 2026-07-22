---
name: circleci-cli
description: "Use when working with CircleCI pipelines, configs, contexts, projects, orbs, runners, env vars, or policies via CLI. Replaces CircleCI MCP with stateless CLI commands. Covers config validation/packing, pipeline trigger/run, context management, orb CRUD, runner management, project env vars, and policy push/decide."
---

# CircleCI CLI

`circleci` CLI installed via Homebrew. Use via `bash` tool calls.

## Auth

```bash
# Initial setup (interactive)
circleci setup

# Non-interactive setup
circleci setup --no-prompt --host https://circleci.com --token $CIRCLECI_TOKEN

# Config file at ~/.circleci/cli.yml
# OR set env vars:
export CIRCLECI_CLI_TOKEN=$CIRCLECI_TOKEN
export CIRCLECI_CLI_HOST=https://circleci.com

# Diagnostic check
circleci diagnostic

# View account info
circleci info
circleci info org
```

## Config

```bash
# Validate config
circleci config validate .circleci/config.yml
circleci config validate .circleci/config.yml --org-slug github/my-org

# Validate with next-gen config
circleci config validate .circleci/config.yml -n

# Validate ignoring deprecated images
circleci config validate .circleci/config.yml --ignore-deprecated-images

# Process (validate + expand)
circleci config process .circleci/config.yml
circleci config process .circleci/config.yml --pipeline-parameters params.yml

# Pack multi-file config into single file
circleci config pack .circleci/
circleci config pack .circleci/ > combined.yml

# Generate config from repo analysis
circleci config generate --language python

# Init a new project
circleci init
```

## Contexts

```bash
# List contexts (requires org-id from Overview page)
circleci context list --org-id <uuid>

# Create context
circleci context create --org-id <uuid> my-context

# Show context env vars
circleci context show --org-id <uuid> my-context

# Store env var in context (value from stdin)
echo "my-value" | circleci context store-secret --org-id <uuid> my-context MY_VAR

# Remove env var from context
circleci context remove-secret --org-id <uuid> my-context MY_VAR

# Delete context
circleci context delete --org-id <uuid> my-context
```

## Pipelines

```bash
# List pipeline definitions for a project
circleci pipeline list <project-slug>

# Create a new pipeline definition
circleci pipeline create <project-id> --name my-pipeline --description "desc" --repo-id <github-repo-id> --file-path .circleci/config.yml

# Run a pipeline (with local config)
circleci pipeline run orgSlug project-id --pipeline-definition-id <id> --local-config-file .circleci/config.yml --parameters key1=value1 --parameters key2=value2

# Run with repo config on specific branch
circleci pipeline run orgSlug project-id --pipeline-definition-id <id> --config-branch main --checkout-branch feature-branch --repo-config
```

## Orbs

```bash
# List orbs
circleci orb list
circleci orb list --detail

# Create orb
circleci orb create my-ns/my-orb --private  # or --public

# Publish orb
circleci orb publish orb.yml my-ns/my-orb@1.0.0
circleci orb publish increment orb.yml my-ns/my-orb  # auto-increment

# Validate orb
circleci orb validate orb.yml

# Process orb (expand pack directives)
circleci orb process orb.yml

# Pack orb source
circleci orb pack src/

# Show orb info
circleci orb info my-ns/my-orb
circleci orb info my-ns/my-orb@1.0.0

# Show orb source
circleci orb source my-ns/my-orb@1.0.0

# Diff orb versions
circleci orb diff my-ns/my-orb@1.0.0 my-ns/my-orb@1.0.1

# Init new orb project
circleci orb init my-orb

# List categories
circleci orb list-categories

# Add/remove orb from category
circleci orb add-to-category my-ns/my-orb category-slug
circleci orb remove-from-category my-ns/my-orb category-slug

# Unlist/relist orb
circleci orb unlist my-ns/my-orb --true   # hide
circleci orb unlist my-ns/my-orb --false  # show
```

## Project env vars

```bash
# List project env vars
circleci project secret list <project-id>

# Create project env var (value from stdin)
echo "prod-db-url" | circleci project secret create <project-id> DATABASE_URL
```

## Runners

```bash
# List runner instances
circleci runner instance list

# List/CRUD resource classes
circleci runner resource-class list --namespace <ns>
circleci runner resource-class create --resource-class my-class --namespace <ns> --description "desc"
circleci runner resource-class delete --resource-class my-class

# List/CRUD runner tokens
circleci runner token list --resource-class my-class
circleci runner token create --resource-class my-class --name my-token
circleci runner token delete <token-id>
```

## Policy

```bash
# Push policy bundle (OPA)
circleci policy push <directory> --context-id <id> --owner-id <owner-id>

# Fetch policy bundle
circleci policy fetch --policy-bundle <bundle-id>

# Diff local vs remote
circleci policy diff <directory>

# Evaluate policy
circleci policy eval <query> <input-file>

# Decision logs
circleci policy logs --context-id <id>

# Decision settings (read)
circleci policy settings --owner-id <owner-id>

# Test policies
circleci policy test <directory>

# Decide (check)
circleci policy decide <config-file>
```

## Local execution

```bash
# Run a job locally via Docker
circleci local execute --job <job-name>
circleci local execute --job <job-name> --env MY_VAR=value
```

## Triggers

```bash
# Create trigger for pipeline
circleci trigger create --pipeline-id <pipeline-id> --schedule "0 6 * * *"
```

## Deploy markers

```bash
# Wire deploy markers into config
circleci deploy init
```

## Output

Most commands support `--json` for machine-readable output:

```bash
circleci context list --org-id <uuid> --json
circleci runner instance list --json
```

## Common patterns

```bash
# Validate before commit
circleci config validate .circleci/config.yml && echo "config OK"

# Pipeline run with local config + params
circleci pipeline run my-org proj-123 --pipeline-definition-id abc \
  --local-config-file .circleci/config.yml \
  --parameters branch=main

# Set env var non-interactively
echo "$MY_SECRET" | circleci context store-secret --org-id <uuid> prod DB_PASS

# Publish orb with auto-increment
circleci orb publish increment orb.yml my-ns/my-orb

# Quick auth check
circleci diagnostic
```

## Gotchas

- Most commands require `CIRCLECI_CLI_TOKEN` or `~/.circleci/cli.yml` with a token
- Context commands require `--org-id` (UUID from org Overview page) — old vcs-type/org-name syntax is deprecated
- `pipeline create` and `pipeline run` are different commands — `create` sets up a pipeline definition, `run` triggers a build
- `project secret` values come from stdin only (no `--value` flag) — use pipe or heredoc
- `runner token create` returns the token only once on creation
- `config validate` returns exit code 0 even with warnings; use `--verbose` to see warnings
- Orb publish requires the orb to exist first (`orb create` before `orb publish`)