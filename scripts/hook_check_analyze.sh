#!/bin/bash
# Claude Code Stop hook — 턴 종료 직전 flutter analyze로 error만 차단.
#
# 정책:
#   - error  : exit 2로 종료 차단(정답이 하나 → 에이전트가 고쳐야 함)
#   - warning: 통과시키되 개수만 보고(의도/방향 판단은 사람 몫)
#   - info   : 무시
#
# 이번 작업으로 .dart 변경이 없으면 analyze를 돌리지 않는다(비-코딩 턴 오버헤드 0).
set -u

cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || exit 0

# .dart 변경(수정·추가)이 없으면 즉시 통과
changed=$(git status --porcelain 2>/dev/null | grep -E '\.dart$')
if [ -z "$changed" ]; then
  exit 0
fi

# error만 fatal — warning/info는 exit 코드에 영향 없음
output=$(flutter analyze --no-fatal-warnings --no-fatal-infos 2>&1)
status=$?

warn_count=$(printf '%s\n' "$output" | grep -cE '^[[:space:]]*warning ')

if [ "$status" -ne 0 ]; then
  echo "❌ flutter analyze: error가 남아 종료할 수 없습니다. 아래 error를 수정 후 다시 시도하세요." >&2
  printf '%s\n' "$output" | grep -E '^[[:space:]]*error ' >&2
  exit 2
fi

if [ "$warn_count" -gt 0 ]; then
  echo "✅ error 0개 — 통과. (warning ${warn_count}개 남아있음 — 사람 판단 필요, 차단 안 함)" >&2
fi
exit 0
