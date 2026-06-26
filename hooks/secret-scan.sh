#!/usr/bin/env bash
# git commit 之前,扫描「已暂存」的改动里有没有疑似密钥。
# Claude Code 在执行 Bash 命令前,会把命令内容以 JSON 喂给这个脚本(走 stdin)。
# 退出码 0 = 放行;退出码 2 = 阻止该命令,并把 stderr 提示回传给 Claude。

payload=$(cat)
command=$(printf '%s' "$payload" | jq -r '.tool_input.command // empty')

# 只管 git commit
case "$command" in
  *"git commit"*) ;;
  *) exit 0 ;;
esac

# 若命令以 `cd <目录>` 开头,先进入该目录,使暂存区检测对准命令真正操作的仓库。
# (处理 `cd repo && git commit` 这种从非仓库父目录跨目录操作的情况。)
cd_target=$(printf '%s' "$command" | sed -nE 's/^[[:space:]]*cd[[:space:]]+("[^"]+"|[^[:space:]&;|]+).*/\1/p' | head -1)
if [ -n "$cd_target" ]; then
  cd_target=$(eval printf '%s' "$cd_target" 2>/dev/null)
  [ -n "$cd_target" ] && [ -d "$cd_target" ] && cd "$cd_target" 2>/dev/null
fi

# 只看这次真正要提交的内容(已 git add 的部分)
staged=$(git diff --cached 2>/dev/null)
[ -z "$staged" ] && exit 0

# 几乎一定是泄密的特征:AWS key、私钥、OpenAI/GitHub/Slack token、以及 key=xxx 这类赋值
patterns='(AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----|sk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{36}|xox[baprs]-[A-Za-z0-9-]+|(api[_-]?key|secret|password|token)[[:space:]]*[:=][[:space:]]*['"'"'"][^'"'"'"]{8,})'

hits=$(printf '%s' "$staged" | grep -nEi "$patterns")

if [ -n "$hits" ]; then
  echo "已拦截:暂存的改动里疑似有密钥,提交已停止。" >&2
  echo "$hits" | head -n 5 >&2
  echo "若确认是误报,请你自己手动 commit。" >&2
  exit 2
fi

exit 0
