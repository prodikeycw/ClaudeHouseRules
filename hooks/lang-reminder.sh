#!/usr/bin/env bash
# 每次用户提交消息时,把语言偏好重新注入上下文,抵消长会话里的"漂移"。
# UserPromptSubmit hook:输出的 additionalContext 会被加进模型上下文。
reminder='回复语言:默认用简体中文。例外——①软件/应用排错(错误信息、栈追踪、日志、调试步骤及其技术说明)用英文;②用户明确要求英文时用英文。代码、命令、文件路径、标识符、专有名词一律保持原文,只切换其周围的叙述文字。'
jq -nc --arg c "$reminder" \
  '{hookSpecificOutput:{hookEventName:"UserPromptSubmit",additionalContext:$c}}'
