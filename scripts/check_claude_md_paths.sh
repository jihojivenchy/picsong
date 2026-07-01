#!/bin/bash
# CLAUDE.md 경로 참조 부패(rot) 검사
#
# 모든 CLAUDE.md에서 백틱으로 감싼 `lib/...` 경로 참조를 추출해
# 실제 존재 여부를 확인한다. 파일 이동/삭제 후 문서가 옛 경로를
# 가리키는 드리프트를 잡는다. (`<placeholder>`·글롭 패턴은 제외)
#
# 위반 시 비-0 종료. Claude PostToolUse hook 및 CI에서 사용한다.
set -u

fail=0

claude_md_list=$(find . -name 'CLAUDE.md' -not -path './.*/*' 2>/dev/null)

for md in $claude_md_list; do
  refs=$(grep -oE '`lib/[^`]+`' "$md" | tr -d '`' | grep -vE '[<>*]' | sort -u)
  [ -z "$refs" ] && continue
  while IFS= read -r ref; do
    if [ ! -e "$ref" ]; then
      echo "❌ [$md] 존재하지 않는 경로 참조: $ref"
      fail=1
    fi
  done <<< "$refs"
done

if [ "$fail" -eq 0 ]; then
  echo "✅ CLAUDE.md 경로 참조 OK"
fi

exit $fail
