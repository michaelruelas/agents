# Readability Audit
**Date:** [YYYY-MM-DD]
**Scope:** [Files / PR branch reviewed]

---

## Summary

[2–3 sentences: overall clarity signal, top pattern of concern, one genuine
positive observation.]

---

## Findings

### RD-001
| Field    | Value                                              |
|----------|----------------------------------------------------|
| Tier     | 🔴 Blocking / 🟡 Follow-up / 🟢 Optional            |
| Decide   | Change now / Defer / Leave as-is                   |
| Location | `path/to/file.ts:14` — `processData()`            |

**Observation:** What the current name or value looks like to a reader.
**Impact:** What misread or slowdown it causes.
**Suggestion:**
```language
// before → after
```

---

[Repeat for each finding.]

---

## Naming Conventions Observed

Derived from this codebase — use as a reference for new contributors.

| Element         | Convention                  | Example                    |
|-----------------|-----------------------------|----------------------------|
| Variables       | [camelCase / snake_case]    | `userId`, `requestPayload` |
| Booleans        | `is` / `has` / `should` prefix | `isActive`, `hasPermission` |
| Functions       | verb + noun                 | `getUser`, `validateToken` |
| Event handlers  | `on` + event                | `onUserCreated`            |
| Classes         | PascalCase singular noun    | `UserRepository`           |
| Constants       | UPPER_SNAKE_CASE            | `MAX_RETRY_COUNT`          |
| Files           | [kebab-case / camelCase]    | `user-service.ts`          |

[Adjust each row to match what was actually found in the codebase.]
