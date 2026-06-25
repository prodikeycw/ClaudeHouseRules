# CLAUDE.md

Global behavioral guidelines for all projects on this machine.
Keep this file short and sharp — broad, stack-specific standards (coverage
targets, framework rules) belong in a project's own CLAUDE.md, not here.

**Tradeoff:** These bias toward caution over speed. For trivial tasks, use judgment.

---

## 0. Response Language

> **Personalize this section.** It reflects the original author's preference.
> Edit the language, or delete this whole section to keep Claude's default (English).

**Reply in Simplified Chinese (简体中文) by default.**

Exceptions — use English:
- Application/software troubleshooting (error messages, stack traces, logs,
  debugging steps, and the technical explanation around them).
- When I explicitly ask for English output.

Code, commands, file paths, identifiers, and technical terms stay in their
original form regardless of language — only the prose around them switches.

---

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

- State assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them — don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If things are unclear, list all the open questions at once and ask — don't
  proceed step-by-step interrupting with one question at a time.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Test: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.
- Remove imports/variables/functions that YOUR changes made unused.

The test: every changed line should trace directly to the request.

## 4. Goal-Driven Execution

Turn vague tasks into verifiable goals before coding:
- "Fix the bug" → "Write a test that reproduces it, then make it pass."
- For multi-step work, state a brief plan with a verify step per item.

Use TDD when it fits the task: write a failing test, make it pass, refactor.

## 5. Close the Loop

**After changing code, verify it yourself — don't hand me unverified work.**

- If there's a way to check your work (run tests, lint, type-check, start the
  app and exercise it), do it before telling me you're done.
- Report what you ran and the result. "Tests pass" must mean you ran them.
- If there's no automated way to verify, say so explicitly and tell me what to check.

---

## 6. Project Folder Structure

> Sections 1–5 are behavioral rules (how to think and change code) and rarely
> change. Sections 6+ are facts about *this machine* (paths, tools) and will.
> If this file ever grows too big, split along this line — keep behavior global,
> push machine facts down to a machine.md or each project's own CLAUDE.md.

All new projects go under `~/Projects/`:

```
~/Projects/
  active/      ← anything actively being built
  archive/     ← dormant or completed projects
  experiments/ ← throwaway / exploratory work
```

- Never create new projects directly in `~/` (home directory).
- Never organize by AI tool (`~/Projects/Claude/`, etc.).

## 7. Portability — Use `$HOME`, Not Hardcoded Paths

Anything that may run on another machine or be shared via Git must use dynamic paths.

- ❌ `/Users/alice/my-tool` (breaks on other machines)
- ✅ `$HOME/my-tool` or `~/my-tool` (shell, CLI examples)
- ✅ `Path.home() / "my-tool"` or `os.path.expanduser("~/my-tool")` (Python)

Apply in: shell scripts, Python paths, cron entries, docs with copy-paste
commands, config files — anything committed to Git.

---

## 8. Coding Style (language-agnostic)

- **File size**: many small files > few large. ~200–400 lines typical, 800 max.
  Organize by feature/domain, not by type.
- **Avoid**: deep nesting (use early returns), magic numbers (use named constants),
  long functions (keep under ~50 lines).
- **Errors**: handle explicitly; never silently swallow. Validate input at boundaries.

> Language-idiomatic rules (naming conventions, immutability, framework
> conventions, coverage targets) belong in the relevant project's CLAUDE.md —
> not this global file. Example: `camelCase` vs `snake_case`, React's `use`
> prefix — these are language/framework-specific, so they live per-project.

---

## 9. Git & GitHub — Never Commit Secrets or Personal Data

**Before every `git add` / `commit` / `push`:**

- **Never commit**: API keys, secret keys, tokens, passwords, `.env` files,
  credentials, private keys (`.pem`, `.key`), or personal data (PII).
- **Never hardcode secrets in source** — use environment variables or a secret manager.
- **Verify `.gitignore`** covers `.env*`, `*.pem`, `*.key`, `credentials*`,
  `secrets*`, and any local config holding secrets — *before* the first commit.
- **Scan staged changes** (`git diff --cached`) before committing. If anything
  sensitive appears, **stop and tell me** — do not commit.
- **Public repos**: double-check no internal hostnames, emails, or personal data
  leak into code, comments, commit messages, or example files.
- **If a secret was already committed**: treat it as compromised — stop, tell me,
  and rotate the key. Removing it in a later commit is **not** enough; it stays
  in git history forever.
- **First commit in a repo**: scan `git status` for nested git repos and symlinks
  before `git add`. They get captured as gitlinks/symlink blobs, and `.gitignore`
  can't fix it afterward — gitignore is ignored for already-tracked paths.
  Gitignore them *first*, then add.

**Commit format**: `<type>: <description>` — types: `feat, fix, refactor, docs,
test, chore, perf, ci`.

## 10. Machine Tools (customize per machine)

> Template placeholder. List the CLI tools you've installed on *this* machine
> that you want Claude to know about, one per line, pointing to a doc file.
> Delete this section if you have none. Example:
>
> ```
> - **mytool** — what it does. See ~/.claude/tools/mytool.md
> ```
