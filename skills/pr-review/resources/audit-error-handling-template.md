# Error Handling Audit
**Date:** [YYYY-MM-DD]
**Scope:** [Files / PR branch reviewed]

---

## Summary

[2–3 sentences: overall resilience signal, highest-risk gap, one honest
positive note.]

---

## Findings

### EH-001
| Field    | Value                                              |
|----------|----------------------------------------------------|
| Tier     | 🔴 Blocking / 🟡 Follow-up / 🟢 Optional            |
| Decide   | Change now / Defer / Leave as-is                   |
| Location | `path/to/file.ts:99` — `createUser()`             |

**Observation:** What the code does (or doesn't do) on failure.
**Impact:** What happens at runtime if this path is hit.
**Suggestion:**
```language
// minimal fix
```

---

[Repeat for each finding.]
