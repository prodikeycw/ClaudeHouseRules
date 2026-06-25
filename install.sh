#!/bin/bash
# ClaudeHouseRules installer — symlinks Claude Code config into ~/.claude
#
# Run on any new Mac/Linux after `git clone`:
#   bash ~/ClaudeHouseRules/install.sh
#
# What it does:
#   1. Backs up any existing ~/.claude files it's about to replace
#   2. Symlinks this repo's files into ~/.claude (CLAUDE.md, rules, hooks, settings.json)
#   3. Future edits in either location stay in sync via the symlink + git
#
# Requires: git, and jq (used by the guardrail hooks). Install jq with:
#   macOS:  brew install jq        (often preinstalled)
#   Debian: sudo apt install jq

set -e

REPO_DIR="$HOME/ClaudeHouseRules"
CLAUDE_DIR="$HOME/.claude"
COMMON_DIR="$CLAUDE_DIR/rules/common"
TOOLS_DIR="$CLAUDE_DIR/tools"
HOOKS_DIR="$CLAUDE_DIR/hooks"
BACKUP_DIR="$HOME/.claude-backup-$(date +%Y%m%d_%H%M%S)"

if [ ! -d "$REPO_DIR" ]; then
    echo "❌ $REPO_DIR not found. Clone it first:"
    echo "   git clone https://github.com/<your-username>/ClaudeHouseRules $REPO_DIR"
    exit 1
fi

mkdir -p "$CLAUDE_DIR" "$COMMON_DIR" "$TOOLS_DIR" "$HOOKS_DIR"

backup_and_link() {
    local target="$1"   # path that should become the symlink
    local source="$2"   # path the symlink should point to

    if [ -f "$target" ] && [ ! -L "$target" ]; then
        mkdir -p "$BACKUP_DIR/$(dirname "${target#$HOME/}")"
        mv "$target" "$BACKUP_DIR/${target#$HOME/}"
        echo "  → backed up $target"
    elif [ -L "$target" ]; then
        rm -f "$target"
    fi
    ln -s "$source" "$target"
    echo "  ✓ linked $target → $source"
}

echo "🔧 Installing ClaudeHouseRules..."
echo ""

backup_and_link "$CLAUDE_DIR/CLAUDE.md" "$REPO_DIR/CLAUDE.md"

for f in "$REPO_DIR"/rules/common/*.md; do
    [ -e "$f" ] || continue
    name=$(basename "$f")
    backup_and_link "$COMMON_DIR/$name" "$f"
done

# Optional machine tools (none shipped by default — add your own under tools/)
for f in "$REPO_DIR"/tools/*.md; do
    [ -e "$f" ] || continue
    name=$(basename "$f")
    backup_and_link "$TOOLS_DIR/$name" "$f"
done

# Enforced guardrail hooks (run by the harness, not advisory markdown)
backup_and_link "$CLAUDE_DIR/settings.json" "$REPO_DIR/settings.json"
for f in "$REPO_DIR"/hooks/*.sh; do
    [ -e "$f" ] || continue
    name=$(basename "$f")
    backup_and_link "$HOOKS_DIR/$name" "$f"
    chmod +x "$f"
done

echo ""
if [ -d "$BACKUP_DIR" ]; then
    echo "📦 Old files backed up to: $BACKUP_DIR"
fi

if ! command -v jq >/dev/null 2>&1; then
    echo "⚠️  jq not found — the guardrail hooks need it. Install: brew install jq (macOS) / sudo apt install jq (Debian)"
fi

echo "✅ Install complete! Restart Claude Code (or open /hooks once) so hooks load."
echo ""
echo "Edit files in $REPO_DIR — git tracks changes automatically."
