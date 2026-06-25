# ClaudeHouseRules

A portable, shareable set of **house rules for [Claude Code](https://claude.com/claude-code)** —
the global behavioral guidelines, coding standards, and *enforced* safety hooks
you want every project on a machine to follow.

Clone it on any Mac/Linux, run one script, and Claude Code picks up the rules.

---

## What's inside

| Path | What it does | Type |
|------|--------------|------|
| `CLAUDE.md` | Global behavioral rules (think before coding, simplicity, surgical changes, verify your work…) | Advisory |
| `rules/common/*.md` | Topic rules: coding-style, testing, security, git-workflow, code-review, etc. | Advisory |
| `hooks/protect-main.sh` | Blocks `git push` to `main`/`master` (override per-repo with a marker file) | **Enforced** |
| `hooks/secret-scan.sh` | Blocks `git commit` when staged changes contain likely secrets | **Enforced** |
| `settings.json` | Wires the two hooks into Claude Code as `PreToolUse` Bash hooks | Config |
| `settings.local.example.json` | Template for machine-specific permissions (copy to `~/.claude/settings.local.json`) | Template |
| `install.sh` | Symlinks everything into `~/.claude/` (with backups) | Installer |

**Advisory vs Enforced:** markdown rules are guidance Claude reads and usually
follows. Hooks are run by Claude Code itself and *cannot* be bypassed — use them
for the things that must never happen (leaking a secret, pushing to main).

---

## Install on a new machine

```bash
# 1. Prerequisites: git + jq (jq powers the hooks)
#    macOS:  brew install git jq      (often preinstalled)
#    Debian: sudo apt install git jq

# 2. Install Claude Code (the CLI) and log in once
npm install -g @anthropic-ai/claude-code
claude            # follow the login prompt, then quit

# 3. Clone this repo
git clone https://github.com/<your-username>/ClaudeHouseRules ~/ClaudeHouseRules

# 4. Run the installer (symlinks into ~/.claude/, backing up anything it replaces)
bash ~/ClaudeHouseRules/install.sh

# 5. Restart Claude Code — rules and hooks are now live
```

> Order matters: install Claude Code **first**, then run `install.sh`. Hooks load
> at startup, so always restart Claude Code after installing.

---

## Customize before you rely on it

This template ships with sensible defaults, but a few things are personal:

1. **Response language** — `CLAUDE.md` section 0 defaults replies to **Simplified
   Chinese**. Edit or delete that section for English (or another language).
2. **Machine tools** — `CLAUDE.md` section 10 is an empty placeholder. List any
   CLI tools you've installed that Claude should know about, or delete the section.
3. **Permissions** — copy `settings.local.example.json` to
   `~/.claude/settings.local.json` and grow its allow-list as you approve tools.
   Don't commit your real `settings.local.json` (it's machine-specific).
4. **Clone URL** — the `<your-username>` placeholders above and in `install.sh`
   point at your own fork once you push this somewhere.

---

## The hooks, in detail

### Protect main
Blocks pushing to `main`/`master`, telling you to branch first. **Escape hatch:**
if a repo's root contains a file named `.claude-allow-main-push`, the block is
skipped for that repo. This template includes the marker (its own `main` is the
working branch); delete it in repos where you want the protection.

```bash
touch .claude-allow-main-push   # allow direct main pushes in THIS repo
```

### Secret scan
Before every `git commit`, scans the staged diff for common secret patterns
(AWS keys, private keys, OpenAI/GitHub/Slack tokens, `password=…` assignments).
On a match it blocks the commit and lists the suspicious lines. False positive?
Commit it yourself manually.

### Turning hooks off
- One repo, one rule → use the marker file above.
- Everything, temporarily → set `"disableAllHooks": true` in `~/.claude/settings.json`.

---

## License

Do whatever you like with it. No warranty — review the hooks before trusting them.
