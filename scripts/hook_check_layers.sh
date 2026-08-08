#!/bin/bash
# Claude Code PostToolUse hook 래퍼.
# 편집 파일이 domain/data/design_system 계층일 때만 경계 검사를 돌리고,
# 위반 시 exit 2로 위반 내용을 Claude에 피드백한다(자동 수정 유도).
INPUT=$(cat)
file_path=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty')

case "$file_path" in
  *lib/domain/*.dart|*lib/data/*.dart|*lib/presentation/design_system/*.dart)
    output=$(cd "$CLAUDE_PROJECT_DIR" 2>/dev/null && bash scripts/check_layers.sh 2>&1)
    if [ $? -ne 0 ]; then
      printf '%s\n' "$output" >&2
      exit 2
    fi
    ;;
esac

exit 0
