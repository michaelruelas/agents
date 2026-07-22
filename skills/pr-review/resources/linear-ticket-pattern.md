# Linear Ticket Fetching Pattern

## Overview

This document defines the pattern for fetching Linear ticket information to provide context for PR reviews. The ticket context helps sub-agents evaluate whether code changes are related to the source ticket and whether they complete the requirements.

## Prerequisites

The `linear` CLI must be installed and authenticated. To verify:

```bash
linear --version
linear auth whoami
```

If not installed, see: https://github.com/schpet/linear-cli#install

## Pattern for Fetching Ticket Information

### Step 1: Identify the Ticket ID

The ticket ID can be obtained from:

1. **Git branch name** (most common):
   ```bash
   linear issue id
   ```
   This extracts the issue ID from the current branch name (e.g., `ENG-123` from `eng-123-feature-description`)

2. **PR description or title**: Look for patterns like `ENG-123`, `ABC-456`, etc.

3. **User input**: Ask the user if not automatically detectable

### Step 2: Fetch Ticket Details

Once the ticket ID is known, fetch the full ticket information:

```bash
linear issue view <TICKET_ID> --json
```

This returns structured JSON with:
- `identifier`: The ticket ID (e.g., `ENG-123`)
- `title`: Ticket title
- `description`: Full description (may include markdown)
- `state`: Current status (e.g., "In Progress", "Todo")
- `assignee`: Who's working on it
- `labels`: Ticket labels
- `priority`: Priority level
- `team`: Team responsible
- `project`: Associated project (if any)
- `milestone`: Associated milestone (if any)

For human-readable output (markdown format):

```bash
linear issue view <TICKET_ID>
```

### Step 3: Fetch Related Comments (Optional)

To understand the full context, including any updates or clarifications:

```bash
linear issue comment list <TICKET_ID> --json
```

This returns all comments on the ticket, which may contain:
- Requirements clarifications
- Design decisions
- Acceptance criteria updates

### Step 4: Parse and Structure for Sub-Agents

Extract key information for sub-agents:

```markdown
## Ticket Context

**ID**: ENG-123
**Title**: Implement user authentication flow
**State**: In Progress
**Priority**: High

**Description**:
The user authentication flow should support:
1. Email/password login
2. OAuth with Google
3. Password reset via email
4. Session management with refresh tokens

**Acceptance Criteria**:
- [ ] Login endpoint returns JWT token
- [ ] OAuth callback handles errors gracefully
- [ ] Password reset sends email with expiring token
- [ ] Refresh token rotates on use

**Key Comments**:
- User mentioned they only need email/password for MVP (comment on 2024-01-15)
```

## Integration with PR Review Workflow

### For the Main Orchestrator (review-pr.md)

In **Phase 1 — Context Intake**, add:

```markdown
### 1.1 Ticket Identification

1. Attempt to extract ticket ID from git branch:
   ```bash
   linear issue id 2>/dev/null || echo ""
   ```

2. If found, fetch ticket details:
   ```bash
   linear issue view <TICKET_ID> --json > /tmp/ticket.json
   linear issue view <TICKET_ID> > /tmp/ticket.md
   linear issue comment list <TICKET_ID> --json > /tmp/ticket-comments.json
   ```

3. If not found on branch, check PR description for ticket ID pattern

4. If still not found, ask user:
   "I couldn't automatically detect a Linear ticket ID. Do you have a ticket ID for this PR? (or press enter to skip ticket context)"

5. Parse ticket information into structured context for sub-agents

6. If no ticket information is available, note it and proceed with code-only review
```

### For Sub-Agents

Pass the ticket context as part of the PR context. Each sub-agent should:

1. **Read the ticket description and acceptance criteria**
2. **Evaluate their specific focus area against ticket requirements**
3. **Flag mismatches between code changes and ticket scope**

Example for `review-code-quality.md`:

```markdown
## Ticket Alignment (New Section)

Evaluate whether the code quality issues affect the ability to complete the ticket:

- Are there complexity issues in code that implements core ticket requirements?
- Does the coupling make it hard to verify ticket acceptance criteria?
- Are there refactoring needs that block ticket completion?

If the ticket is unavailable or incomplete, note it and proceed with standard code quality evaluation.
```

## Error Handling

### Linear CLI Not Installed

If `linear` command is not available:

```bash
if ! command -v linear &> /dev/null; then
    echo "Linear CLI not installed. Install: https://github.com/schpet/linear-cli#install"
    echo "Proceeding without ticket context..."
fi
```

### Not Authenticated

If `linear auth whoami` fails:

```bash
if ! linear auth whoami &> /dev/null; then
    echo "Linear CLI not authenticated. Run: linear auth login"
    echo "Proceeding without ticket context..."
fi
```

### Ticket Not Found

If the ticket ID doesn't exist or isn't accessible:

```bash
if ! linear issue view <TICKET_ID> &> /dev/null; then
    echo "Ticket <TICKET_ID> not found or not accessible"
    echo "Proceeding without ticket context..."
fi
```

### No Ticket ID Detectable

If no ticket ID can be found:

```markdown
**Note**: No Linear ticket ID detected. The review will focus on code quality
without ticket alignment evaluation. If this PR is associated with a ticket,
please provide the ticket ID for a more comprehensive review.
```

## Best Practices

1. **Always try to fetch ticket context** - it provides valuable alignment information
2. **Don't block on missing ticket** - proceed with code-only review if unavailable
3. **Pass ticket context to all sub-agents** - they can each evaluate their focus area against requirements
4. **Flag scope mismatches** - if code changes seem unrelated to the ticket, flag it
5. **Verify acceptance criteria** - check if the code changes address the ticket's acceptance criteria

## Example Workflow

```bash
# Main orchestrator fetches ticket context
TICKET_ID=$(linear issue id 2>/dev/null || echo "")

if [ -n "$TICKET_ID" ]; then
    echo "Fetching ticket context: $TICKET_ID"
    linear issue view $TICKET_ID --json > audits/ticket-context.json
    linear issue view $TICKET_ID > audits/ticket-context.md
    linear issue comment list $TICKET_ID --json > audits/ticket-comments.json
    
    # Parse key information
    TICKET_TITLE=$(jq -r '.title' audits/ticket-context.json)
    TICKET_DESCRIPTION=$(jq -r '.description' audits/ticket-context.json)
    
    echo "Ticket: $TICKET_ID - $TICKET_TITLE"
else
    echo "No ticket ID detected. Proceeding with code-only review."
fi

# Pass ticket context to sub-agents
# (this happens via the context intake phase)
```
