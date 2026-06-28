# ClaudeHouseRules

A portable, shareable set of **house rules for [Claude Code](https://claude.com/claude-code)** —
the global behavioral guidelines, coding standards, and *enforced* safety hooks
you want every project on a machine to follow.

Clone it on any Mac/Linux, run one script, and Claude Code picks up the rules.

---

## 中文快速上手

一套可移植、可分享的 **Claude Code「家规」**:全局行为准则、编码规范,以及**强制安全 hook**
(拦截推送 `main`、提交前扫描密钥)。在任意 Mac/Linux 上克隆、跑一个脚本即可生效。

**两类规则:** Markdown 是「建议」(Claude 读取后通常遵守);hook 由 Claude Code 自己执行、**绕不过**
——用于绝不能发生的事(泄露密钥、误推 main)。

**新机器安装(5 步):**

```bash
# 1. 装依赖:git + jq(jq 给 hook 用)
#    macOS: brew install git jq   |   Debian: sudo apt install git jq
# 2. 装 Claude Code 并登录一次
npm install -g @anthropic-ai/claude-code && claude
# 3. 克隆本仓库
git clone https://github.com/<你的用户名>/ClaudeHouseRules ~/ClaudeHouseRules
# 4. 运行安装脚本(软链进 ~/.claude/,自动备份被替换的文件)
bash ~/ClaudeHouseRules/install.sh
# 5. 重启 Claude Code —— 规则与 hook 生效
```

> 顺序要点:**先装 Claude Code,再跑 `install.sh`**。hook 在启动时加载,装完务必重启。

**用前需自定义:**
1. **回复语言** —— 默认简体中文,由三处共同保证:`CLAUDE.md` 第 0 节、`settings.json` 的
   `"language": "chinese"`、以及 `hooks/lang-reminder.sh`(每轮重注入,防漂移)。想换语言:
   改这三处的文字 + `language` 值;想完全交给默认(英文):删掉 `language` 字段和
   `UserPromptSubmit` hook 即可。
2. **机器工具** —— `CLAUDE.md` 第 10 节是空占位符,可填你装的 CLI 工具或删掉。
3. **权限** —— 把 `settings.local.example.json` 复制为 `~/.claude/settings.local.json`,别提交真实版。
4. **放行 main** —— 某仓库想直推 main,就在其根目录 `touch .claude-allow-main-push`。

> 下方为完整英文文档 / Full English documentation below.

---

## What's inside

| Path | What it does | Type |
|------|--------------|------|
| `CLAUDE.md` | Global behavioral rules (think before coding, simplicity, surgical changes, verify your work…) | Advisory |
| `rules/common/*.md` | Topic rules: coding-style, testing, security, git-workflow, code-review, etc. | Advisory |
| `hooks/protect-main.sh` | Blocks `git push` to `main`/`master` (override per-repo with a marker file) | **Enforced** |
| `hooks/secret-scan.sh` | Blocks `git commit` when staged changes contain likely secrets | **Enforced** |
| `hooks/lang-reminder.sh` | Re-injects the response-language rule on every prompt so it doesn't drift in long sessions | **Enforced** |
| `settings.json` | Wires the hooks into Claude Code + sets native `language` preference | Config |
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

1. **Response language** — defaults to **Simplified Chinese**, enforced in three
   places: `CLAUDE.md` section 0, `settings.json`'s `"language": "chinese"`, and
   `hooks/lang-reminder.sh` (re-injected every prompt so it doesn't drift in long
   sessions). To change language, edit the text in those three + the `language`
   value. To fall back to the default (English), delete the `language` field and
   the `UserPromptSubmit` hook from `settings.json`.
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
