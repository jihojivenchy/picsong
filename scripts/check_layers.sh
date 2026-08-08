#!/bin/bash
# 계층 의존 방향 가드 (Clean Architecture 경계 검사)
#
# 의존 방향: presentation → domain ← data
#   - domain        : 외부 프레임워크/상위 계층 의존 0 (순수 Dart만)
#   - data          : presentation을 import 금지 (예외 없음 — 콜백 주입으로 해결)
#   - design_system : Bloc/라우터/화면/데이터 계층 import 금지 (Context-Free)
#
# 위반 시 비-0 종료. Claude PostToolUse hook 및 CI에서 사용한다.
set -u

fail=0

# domain은 UI/외부 프레임워크/상위 계층을 import할 수 없다 (domain/CLAUDE.md §1-2)
domain_hits=$(grep -rnE \
  "import .*(package:flutter/|package:flutter_bloc/|package:bloc/|package:equatable/|package:go_router/|package:get/|package:dio/|package:hive|package:firebase|/presentation/|/data/)" \
  lib/domain --include='*.dart' || true)
if [ -n "$domain_hits" ]; then
  echo "❌ [domain] 외부/상위 계층 import 금지 — 색상·아이콘은 presentation extension으로 분리:"
  echo "$domain_hits"
  fail=1
fi

# data는 presentation을 import할 수 없다 (data/CLAUDE.md §5)
# presentation 반응이 필요하면 콜백 노출 후 main에서 주입 (예: DioInterceptor.onSessionExpired)
data_hits=$(grep -rnE "import .*presentation/" lib/data --include='*.dart' || true)
if [ -n "$data_hits" ]; then
  echo "❌ [data] presentation import 금지 — 콜백을 노출하고 컴포지션 루트(main)에서 주입:"
  echo "$data_hits"
  fail=1
fi

# design_system은 Cubit/라우터/화면/데이터를 알 수 없다 (design_system/CLAUDE.md §2-3)
ds_hits=$(grep -rnE \
  "import .*(package:flutter_bloc/|package:go_router/|/presentation/screens/|/data/)" \
  lib/presentation/design_system --include='*.dart' || true)
if [ -n "$ds_hits" ]; then
  echo "❌ [design_system] Bloc/라우터/화면/데이터 import 금지 — 데이터는 파라미터, 이벤트는 콜백으로:"
  echo "$ds_hits"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "✅ 계층 경계 OK"
fi

exit $fail
