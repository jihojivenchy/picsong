#!/bin/bash
# 계층 의존 방향 가드 (Clean Architecture 경계 검사)
#
# 의존 방향: presentation → domain ← data
#   - domain : 외부 프레임워크/상위 계층 의존 0 (순수 Dart만)
#   - data   : presentation을 import 금지
#
# 위반 시 비-0 종료. Claude PostToolUse hook 및 CI에서 사용한다.
set -u

fail=0

# domain은 UI/외부 프레임워크/상위 계층을 import할 수 없다 (domain/CLAUDE.md §1-2)
domain_hits=$(grep -rnE \
  "import .*(package:flutter/|package:get/|package:dio/|package:hive|package:firebase|/presentation/|/data/)" \
  lib/domain --include='*.dart' || true)
if [ -n "$domain_hits" ]; then
  echo "❌ [domain] 외부/상위 계층 import 금지 — 색상·아이콘은 presentation extension으로 분리:"
  echo "$domain_hits"
  fail=1
fi

# data는 presentation을 import할 수 없다 (data/CLAUDE.md §5)
# 의도된 예외: dio_interceptor.dart — 401 시 로그인 화면으로 강제 이동
data_hits=$(grep -rnE "import .*presentation/" lib/data --include='*.dart' \
  | grep -vE "dio_interceptor\.dart" || true)
if [ -n "$data_hits" ]; then
  echo "❌ [data] presentation import 금지:"
  echo "$data_hits"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "✅ 계층 경계 OK"
fi

exit $fail
