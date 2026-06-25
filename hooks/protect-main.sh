#!/usr/bin/env bash
# 拦截推送到 main/master 的操作。
# Claude Code 在执行 Bash 命令前,会把命令内容以 JSON 喂给这个脚本(走 stdin)。
# 退出码 0 = 放行;退出码 2 = 阻止该命令,并把 stderr 提示回传给 Claude。

payload=$(cat)
command=$(printf '%s' "$payload" | jq -r '.tool_input.command // empty')

# 只管 git push,其它命令一律放行
case "$command" in
  *"git push"*) ;;
  *) exit 0 ;;
esac

# 逃生口:仓库根目录有 .claude-allow-main-push 标记 → 允许直推 main
# (用于个人/配置类仓库,这类仓库本来就以 main 为工作分支)
repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
[ -n "$repo_root" ] && [ -f "$repo_root/.claude-allow-main-push" ] && exit 0

# 当前在哪个分支?
branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

# 两种情况拦截:① 当前正站在 main/master 上推送;② 命令里直接点名了 main/master
if [ "$branch" = "main" ] || [ "$branch" = "master" ] \
   || printf '%s' "$command" | grep -Eq '(^|[[:space:]])(main|master)([[:space:]]|$)'; then
  echo "已拦截:拒绝推送到受保护分支(main/master)。" >&2
  echo "请先建分支:  git switch -c my-change" >&2
  exit 2
fi

exit 0
