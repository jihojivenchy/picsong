# lib/utils/ — Utility Layer Guardrails

도메인 지식 없이 어디서든 쓰일 수 있는 **범용 유틸리티** 자리입니다.

---

## 1. 디렉터리 책임

| 경로 | 책임 |
|---|---|
| `extensions/` | 표준 타입/외부 타입에 메서드 추가(`DateTime`, `String`, `GetInterface` 등). 부작용 없음. |
| `services/` | 진짜 범용 인프라(`Debouncer`, `AppLogger`). 도메인 종속 서비스는 여기 두지 않는다. |

## 2. 무엇이 utils가 아닌가

다음에 해당하면 **utils가 아니다.** 적절한 계층으로 옮긴다.

* 특정 도메인 어휘(예매/리뷰/세차 등)를 알아야 동작 → `domain/` 또는 `data/`.
* GetX 컨트롤러나 화면 상태에 직접 의존 → `presentation/`.
* API 호출/스토리지/외부 SDK 사용 → `data/services/`.
* 컨트롤러/위젯에 합성되는 mixin(위치 권한 보조 등) → `presentation/common/mixins/`. (utils에는 mixin을 두지 않는다.)

## 3. Extension 규칙
* 파일명은 `<대상>_<역할>.dart` 또는 `<역할>_extension.dart` 컨벤션 유지.

## 4. Service 규칙
* 진짜 범용일 때만 둔다(`Debouncer`, `AppLogger`).
* 도메인 키워드가 등장하면 즉시 `data/services/`로 이동.
* 인스턴스 보유가 필요하면 명시적 생성 또는 DI(`get_it`)를 통해서만 노출.

## 5. 금지 사항
* `BuildContext`, `Widget` 의존 금지(꼭 필요하면 `presentation/services/`로).
