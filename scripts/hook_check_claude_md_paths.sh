#!/bin/bash
# Claude Code PostToolUse hook 래퍼.
# CLAUDE.md 또는 lib 하위 .dart 편집 시 CLAUDE.md 경로 참조 검사를 돌리고,
# 위반 시 exit 2로 위반 내용을 Claude에 피드백한다(문서 동기화 유도).
INPUT=$(cat)
file_path=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')

case "$file_path" in
  *CLAUDE.md|*lib/*.dart)
    output=$(cd "$CLAUDE_PROJECT_DIR" 2>/dev/null && bash scripts/check_claude_md_paths.sh 2>&1)
    if [ $? -ne 0 ]; then
      printf '%s\n' "$output" >&2
      exit 2
    fi
    ;;
esac

exit 0
