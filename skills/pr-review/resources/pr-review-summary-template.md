# PR Review: [PR Title or Branch Name]
**Date:** [YYYY-MM-DD]
**Files reviewed:** [N files, +N -N]

---

## Executive Summary

[2–4 sentences. What does this PR do? Is the approach sound? What is the
one area most worth the author's attention? End with a merge-readiness
signal: ready / ready with minor changes / needs discussion on X first.
Write this like you're telling a teammate where things stand — not like
a status report.]

---

## Priority Issue Table

| ID     | Tier         | File : Line      | Summary                              | Decide       |
|--------|--------------|------------------|--------------------------------------|--------------|
| CQ-001 | 🔴 Blocking   | `src/foo.ts:42`  | Off-by-one in page cursor            | Change now   |
| EH-002 | 🟡 Follow-up  | `src/bar.ts:88`  | Unhandled rejection in background job| Defer        |
| RD-003 | 🟢 Optional   | `src/baz.ts:14`  | `d` → `document` for clarity        | Leave as-is  |

---

## Ticket Alignment (if ticket context available)

### Ticket Context
- **ID**: [TICKET_ID or "Not available"]
- **Title**: [ticket title or "N/A"]
- **State**: [ticket state or "N/A"]

### Scope Alignment
[Summary of whether changes are related to the ticket. List any out-of-scope changes.]

### Completeness
[Summary of whether changes complete the ticket requirements. List any missing acceptance criteria.]

### Ticket Alignment Findings
[List any TA- findings from the ticket-alignment audit]

---

## Categorized Findings

### Code Quality
### Structural Choices
### Error Handling
### Readability
### Ticket Alignment

---

## Suggested PR Comments

These are starting points — the reviewer should rewrite them in their own
voice before posting. The full draft with file/line mapping for inline
comments is in `audits/pr-comments-draft.md`.

[3–5 comments in natural prose. No formula. Vary the length and style.
Some can be one line, some a short paragraph. Write them like you'd
actually say them to the author.]

---

## What's Working Well

[1–3 genuine, specific observations with file and line citations.
Keep this real — don't invent praise to balance the review.]
