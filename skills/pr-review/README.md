# pr-reviewer

A comprehensive PR review skill. Reviews code like a pragmatic senior engineer —
calm, specific, and non-accusatory. Focuses on things that matter: correctness,
maintainability, coupling, readability, and future change risk. Helps the author
decide whether to fix something now, defer it, or leave it alone.

---

## Installation (One Command)

**Via agentskill.sh (all platforms):**
```bash
npx @agentskill.sh/cli@latest setup
```
Then in any session: `/learn @michaelruelas/pr-reviewer`

**Manual install for OpenCode:**
```bash
mkdir -p ~/.config/opencode/skills && \
git clone https://github.com/michaelruelas/pr-reviewer && \
cp -r pr-reviewer ~/.config/opencode/skills/pr-reviewer
```
Restart OpenCode and invoke `@pr-reviewer`.

---

## Usage

### Claude Code / Cowork

Provide the PR diff by pasting it, giving a file path, or sharing a GitHub URL.
Say "review this PR" and the skill activates automatically.

### OpenCode

After installing, invoke `@pr-reviewer` in any session.

---

## What It Produces

- **`audits/pr-review-summary.md`** — executive summary, prioritized issue
  table, and 3–5 copy-paste-ready PR comments
- **`audits/code-quality.md`** — complexity, coupling, cohesion findings
- **`audits/design-pattern.md`** — structural choices and alternatives
- **`audits/error-handling.md`** — error paths, async safety, recovery gaps
- **`audits/readability.md`** — naming, clarity, signatures, magic values
- **`audits/solid-principles.md`** — coupling, extensibility, dependency structure

---

## Sub-Agents

The skill runs five specialized sub-agents in parallel:

| Agent | Focus |
|-------|-------|
| `review-code-quality` | Complexity, coupling, cohesion, LOC |
| `review-design-pattern` | Structural choices and practical alternatives |
| `review-error-handling` | Error paths, async safety, recovery |
| `review-readability` | Naming, clarity, signatures, magic values |
| `review-solid-principles` | Coupling, extensibility, dependency structure |

---

## Review Philosophy

This skill embodies a specific set of values about how code review should work:

- **Assume good intent.** The author had a reasonable reason for every choice
  unless there is a clear bug.
- **Focus on the diff.** Pre-existing issues outside the changed code are out
  of scope.
- **Three tiers, not ten.** Every finding is Blocking, Follow-up, or Optional —
  and every finding says whether to change it now, defer, or leave it alone.
- **No framework-policing.** SOLID, GoF patterns, and similar frameworks are
  only named when the name itself helps the author act. Otherwise the finding
  describes the practical problem and impact.
- **No speculative performance claims.** Performance is flagged only when there
  is an algorithmic reason or a measurement.
- **Refactors are optional by default.** A refactor is only Blocking if it
  fixes a bug or unblocks a change already in progress.

---

## Repository Structure

```
pr-reviewer/
├── SKILL.md                          # Skill entry point (all platforms)
├── README.md
├── .gitignore
└── agents/                           # Sub-agents (dispatched by orchestrator)
    ├── review-pr.md                  # OpenCode orchestrator (invoked via @pr-reviewer)
    ├── review-code-quality.md        # Complexity, coupling, cohesion
    ├── review-design-pattern.md      # Structural choices
    ├── review-error-handling.md      # Error paths and resilience
    ├── review-readability.md         # Naming and clarity
    └── review-solid-principles.md    # Coupling and extensibility
```

**`SKILL.md`** is the entry point for all platforms. It contains the
orchestration logic, tone contract, tier definitions, and pointers to the
agent files.

**`agents/review-pr.md`** is the OpenCode orchestrator — it contains the same
orchestration logic with OpenCode-specific frontmatter (`mode: primary`,
`permission`, `tools`). OpenCode loads it via the `@pr-reviewer` mention.

The five sub-agent files are read as reference documents by the orchestrator
during the review run.

---

## Customization

### Adjusting the tone

The tone contract lives in two places:
- `SKILL.md` under **Tone Contract** (used by Claude)
- `agents/review-pr.md` under **Tone & Language Guide** (used by OpenCode)

Edit both to change how findings are framed across the board.

### Adjusting tier thresholds

The tier definitions and decide values are in `SKILL.md` and mirrored in each
sub-agent file. Raise or lower the bar for Blocking vs. Follow-up by editing
the criteria table in the relevant file.

### Adding a sub-agent

1. Create `agents/review-<name>.md` following the structure of any existing
   sub-agent (frontmatter, role, tone guide, tier definitions, checklist,
   unable-to-verify protocol, output template).
2. Add a row to the dispatch table in `SKILL.md`.
3. Add a row to the Categorized Findings section of the summary template.

---

## License

MIT
