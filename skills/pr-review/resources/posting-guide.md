# Posting Inline PR Comments — Guide

> **GUARDRAIL:** Do not post any PR comment, review, or approval without
> **explicit approval** from the user. The review artifacts (summary,
> draft comments) are local files. Posting to GitHub is a separate step
> that the user must explicitly request.
>
> **GUARDRAIL:** Never change the status of a PR. Do not close, merge,
> reopen, or mark a PR as ready/draft. This includes `gh pr close`,
> `gh pr merge`, `gh pr ready`, `gh pr draft`, or any API call that
> alters PR state. Closing someone's PR without their knowledge is
> disruptive and erodes trust. If you think a PR should be closed,
> note it in the review summary — do not act on it.

This guide covers how to attach line-specific review comments to GitHub
pull requests. Use this when the user has reviewed the draft comments in
`audits/pr-comments-draft.md`, made their edits, and explicitly asked you
to post them.

---

## Prerequisites

1. GitHub CLI installed and authenticated:
   ```bash
   gh auth status
   ```
2. You need the PR number, repo owner/name, and the head commit SHA.

---

## Approach Priority

1. **MCP tool** (if available): `mcp__github_inline_comment__create_inline_comment`
   — best GitHub UI integration.
2. **`gh api` with `/reviews` endpoint**: for posting multiple comments as
   a single review (preferred — one notification, atomic).
3. **`gh api` with `/comments` endpoint**: for posting a single comment.

---

## Gathering PR Info

```bash
# Get the PR head commit SHA (required for all comment posting)
gh api repos/{owner}/{repo}/pulls/{pr_number} --jq '.head.sha'

# List changed files
gh api repos/{owner}/{repo}/pulls/{pr_number}/files \
  --jq '.[] | "\(.filename): +\(.additions)/-\(.deletions)"'

# Check for pending reviews (GitHub allows only one per user)
gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews \
  --jq '.[] | select(.state=="PENDING")'
```

---

## Posting Multiple Comments as a Single Review

Use this when posting the full set of draft comments at once. This is the
recommended approach — all comments appear as one cohesive review with a
single notification.

```bash
cat <<'EOF' | gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews --input -
{
  "event": "COMMENT",
  "body": "Overall review summary from the reviewer's draft.",
  "comments": [
    {
      "path": "src/components/CourseCard.tsx",
      "body": "Comment text here in natural prose.",
      "side": "RIGHT",
      "line": 25
    },
    {
      "path": "src/utils/validation.ts",
      "body": "Another comment here.",
      "side": "RIGHT",
      "line": 42
    }
  ]
}
EOF
```

### Review Event Types

| Event             | When to use                                    |
|-------------------|------------------------------------------------|
| `COMMENT`         | Leaving feedback without approving or blocking |
| `APPROVE`         | Changes look good, ready to merge              |
| `REQUEST_CHANGES` | Issues must be fixed before merge              |

---

## Posting a Single Comment

Use this for one-off comments or when a pending review is blocking the
reviews endpoint.

```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments \
  -f body='Comment text here in natural prose.' \
  -f commit_id='{commit_sha}' \
  -f path='src/utils/validation.ts' \
  -F line=45 \
  -f side='RIGHT'
```

### Multi-line Comment

```bash
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments \
  -f body='Comment spanning multiple lines.' \
  -f commit_id='{commit_sha}' \
  -f path='src/utils/parser.ts' \
  -F start_line=10 \
  -f start_side='RIGHT' \
  -F line=15 \
  -f side='RIGHT'
```

---

## Parameter Reference

| Parameter    | Type    | Required | Description                                          |
|--------------|---------|----------|------------------------------------------------------|
| `body`       | string  | Yes      | Comment text (supports Markdown)                     |
| `commit_id`  | string  | Yes*     | SHA of the commit to comment on                      |
| `path`       | string  | Yes      | Relative path to the file                            |
| `line`       | integer | Yes      | Line number in the diff (use `-F` for integers)      |
| `side`       | string  | Yes      | `RIGHT` for new/modified lines, `LEFT` for deleted   |
| `start_line` | integer | No       | Start line for multi-line comments                   |
| `start_side` | string  | No       | Start side for multi-line comments                   |
| `event`      | string  | Reviews  | `COMMENT`, `APPROVE`, or `REQUEST_CHANGES`           |

*`commit_id` is required for single comments, optional for reviews.

### Flag Reference

- `-f` — string field
- `-F` — integer field (capital F)

---

## Common Issues

### "user_id can only have one pending review per pull request"

GitHub allows one pending review per user. Check for pending reviews and
either submit them or use the single comment endpoint instead.

### "Pull request review thread line must be part of the diff"

The line number doesn't exist in the diff for that file. Verify the file
was changed in this PR and check the "Files changed" tab for actual line
numbers.

### "commit_sha is not part of the pull request"

Get the latest commit SHA:
```bash
gh api repos/{owner}/{repo}/pulls/{pr_number} --jq '.head.sha'
```

---

## Approval Checklist

Before posting, confirm with the user:

1. **Has the user explicitly approved posting?** — Do not proceed without a
   clear "yes", "post them", "go ahead", or equivalent.
2. **Has the user reviewed and edited the draft?** — The draft in
   `audits/pr-comments-draft.md` should reflect the user's voice, not the
   raw skill output.
3. **Which comments to post?** — The user may want to post all, some, or
   none. Ask which ones.
4. **What event type?** — `COMMENT` for feedback, `APPROVE` if approving,
   `REQUEST_CHANGES` if blocking.
5. **Is the overall PR comment included?** — The user may want to post the
   summary comment separately from the inline comments.
