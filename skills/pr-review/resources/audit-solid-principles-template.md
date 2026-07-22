# Structural & Dependency Audit
**Date:** [YYYY-MM-DD]
**Scope:** [Files / PR branch reviewed]

---

## Summary

[2–3 sentences: where the structure handles change well, where the main
coupling risk is. Honest and specific.]

---

## Findings

### SP-001
| Field    | Value                                              |
|----------|----------------------------------------------------|
| Tier     | 🔴 Blocking / 🟡 Follow-up / 🟢 Optional            |
| Decide   | Change now / Defer / Leave as-is                   |
| Location | `path/to/file.ts:1` — `UserService`               |

**Observation:** What the code currently does structurally.
**Impact:** What the next likely change will cost, or what is already
broken.
**Suggestion:**
```language
// minimal sketch of the improved structure
```

---

[Repeat for each finding.]

---

## Structural Snapshot

[One short paragraph or table describing the overall dependency flow of
the changed code: what depends on what, where the seams are, what is
easy to test vs. hard. Helps the author see the big picture.]
