---
name: commit-message-lint
description: "Use when writing or committing a git commit message. Ensures all commits pass commitlint validation by reading the enforced convention first, writing a compliant message, and self-correcting from hook rejections. Triggers on phrases like 'commit', 'git commit', 'commit message', 'commitlint', or when a commit fails validation."
argument-hint: ""
---

# Commit Message Lint

This project uses commitlint with Linear ticket format. All commit messages MUST start with a ticket number (SHO-123:) and pass validation before the commit completes. The commit-msg hook is the final gate — never bypass it with `--no-verify`.

## Detect commitlint configuration

Any of these means commitlint is active:

```bash
# Config file check
ls .commitlintrc* commitlint.config.* .husky/commit-msg 2>/dev/null

# Print enforced rules
npx commitlint --print-config
```

## Project-specific rules

This project enforces the following:

| Rule | Value | What it means |
|------|-------|---------------|
| `linear-ticket-format` | `[2, "always"]` | Must start with `SHO-` + digits + `:` + space |
| `header-max-length` | `[2, "always", 100]` | Header must be ≤ 100 characters |
| `subject-case` | `[2, "never", ["sentence-case", "start-case", "pascal-case", "upper-case"]]` | Subject must be imperative mood, lowercase first word |
| `subject-full-stop` | `[2, "never", "."]` | Subject must NOT end with a period |

## Commit message format

```
SHO-123: subject
```

Example: `SHO-456: release potluck slots on decline`

## Subject rules (imperative mood)

The subject is the third-person singular present command form:

| Intent | BAD | GOOD |
|--------|-----|------|
| Add feature | `SHO-123: Added support` | `SHO-123: add support` |
| Fix bug | `SHO-123: Fixed the bug` | `SHO-123: fix the bug` |
| Remove code | `SHO-123: Removed dead code` | `SHO-123: remove dead code` |
| Refactor | `SHO-123: Refactored to use enums` | `SHO-123: use enum constants` |

**Never use**: sentence-case, past tense, trailing period, or description longer than ~80 characters.

## Header length rule

Header = `SHO-` + digits + `: ` + `subject`

Must be ≤ 100 characters total. Keep the subject short.

| BAD | GOOD |
|-----|------|
| `SHO-123: Fixed bug where potluck slots were not released on decline` (152 chars) | `SHO-123: release potluck slots on decline` (47 chars) |
| `SHO-456: Replaced hardcoded string literals with proper enum constants` (176 chars) | `SHO-456: use enum constants` (36 chars) |

## Validate before committing

Always validate your message before running `git commit`:

```bash
# Test your message
printf '%s' "SHO-456: release potluck slots on decline" | npx commitlint

# Or with a body
printf '%s' "SHO-456: release potluck slots on decline

Previously the tRPC procedure did not match the REST endpoint behavior." | npx commitlint
```

Exit 0 = pass. Non-zero = fix the message.

## Self-correct when the hook rejects

The hook output names each violated rule in brackets:

```
⧗   --- input ---
SHO-123: Fixed bug where potluck slots were not released on decline.
✖   header must not be longer than 100 characters, current length is 152 [header-max-length]
✖   subject must not be sentence-case, start-case, pascal-case, upper-case [subject-case]
✖   subject may not end with full stop [subject-full-stop]
```

**Fix only the named rules.** Then re-validate via stdin before retrying.

```bash
# Corrected message
printf '%s' "SHO-123: release potluck slots on decline" | npx commitlint

# Amend without re-staging (changes remain staged after failed commit)
git commit --amend -m "SHO-123: release potluck slots on decline"
```

**Never use `git commit --no-verify`** — fixing the message is always the correct action.

## Setup commitlint for Linear tickets

If commitlint is not yet configured:

### 1. Install dependencies

```bash
npm install --save-dev @commitlint/cli husky
```

### 2. Create `commitlint.config.js`

```js
module.exports = {
  parserPreset: {
    parserOpts: {
      headerPattern: /^SHO-\d+: (.+)$/,
      headerCorrespondence: ['subject']
    }
  },
  plugins: [
    {
      rules: {
        'linear-ticket-format': ({ header }) => {
          const linearRegex = /^SHO-\d+: /;
          const isValid = linearRegex.test(header);
          return [
            isValid,
            'Your commit message must start with a valid ticket number. Example: "SHO-123: Fix auth bug"'
          ];
        }
      }
    }
  ],
  rules: {
    'linear-ticket-format': [2, 'always']
  }
};
```

### 3. Initialize Husky

```bash
npx husky init
```

### 4. Create commit-msg hook

`.husky/commit-msg`:

```
npx commitlint --edit "$1"
```

```bash
chmod +x .husky/commit-msg
```

## Anti-patterns

- **Missing ticket prefix**: `release potluck slots` → fails `linear-ticket-format`
- **Wrong ticket format**: `SHO-123:fix bug` (missing space) → fails `linear-ticket-format`
- **Sentence-case subject**: `SHO-123: Fixed bug` → fails `subject-case`
- **Trailing period**: `SHO-123: fix bug.` → fails `subject-full-stop`
- **Header > 100 chars**: keeps subject too long → fails `header-max-length`
- **Past tense**: `SHO-123: Added`, `Fixed`, `Removed` → fails `subject-case`
- **Detailed explanation in subject**: put details in body or keep subject short