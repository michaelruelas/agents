# PR Comment Draft — [PR Title or Branch Name]

> **This is your working copy.** Read through, edit, rewrite, or delete
> comments until they sound like *you*. The tier and decide fields are
> for your reference — don't include them in the posted comment.
>
> **Do not post these comments to GitHub without explicit approval from
> the user.** When the user approves posting, follow the instructions in
> `resources/posting-guide.md` (or use the `/attach-review-to-pr` skill)
> to attach inline comments to the PR.

---

## Comment 1
**File:** `path/to/file.ts`
**Line:** 42
**Tier:** 🔴 Blocking — Change now

This loop skips the last element because the condition uses `<` instead
of `<=`. Quick fix:

```ts
for (let i = 0; i <= items.length; i++) {
```

---

## Comment 2
**File:** `path/to/file.ts`
**Line:** 88
**Tier:** 🟡 Follow-up — Defer

If the DB call here throws, the promise rejects silently and the caller
has no signal. Might be worth a `.catch` or a try/catch — but fine to
handle in a follow-up if this isn't on the critical path.

---

## Comment 3
**File:** `path/to/file.ts`
**Line:** 14
**Tier:** 🟢 Optional — Leave as-is

Minor thing: `d` could be `document`, `data`, or `delta` at a glance.
Took me a second to orient. No rush on this one.

---

## Overall PR Comment

[1–3 sentences for the PR-level comment. What's the overall impression?
Is this ready to merge? Keep it conversational — like you're telling
a teammate where things stand.]

---

## Comments I'm NOT Posting (internal reference)

[Any findings from the audit that were valid but not worth a public
comment. Kept here so the reviewer has full context.]
