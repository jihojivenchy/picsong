# lib/presentation/design_system/ — Design System Guardrails

재사용 UI 컴포넌트(`components/`)와 디자인 토큰(`foundation/`)을 정의하는 계층입니다.
이 문서는 **컴포넌트를 만들고 수정하는 규칙**입니다. 화면에서 컴포넌트를 *사용하는* 규칙은 `lib/presentation/CLAUDE.md`의 "디자인 시스템 사용 규칙"을 따릅니다.

---

## 1. 디렉터리 책임

| 경로 | 책임 |
|---|---|
| `foundation/` | 디자인 토큰. `app_colors.dart`(색상), `app_fonts.dart`(폰트), `app_spacing.dart`(간격), `app_radius.dart`(라디우스), `image_paths.dart`/`lottie_paths.dart`(에셋 경로) |
| `components/` | 화면-독립적 재사용 위젯. 역할별 하위 폴더(`button/`, `text/`, `bottom_sheet/` 등) |

## 2. Context-Free 원칙 (최우선)

컴포넌트는 어떤 화면에 놓여도 동작해야 한다.

* 특정 화면/피처의 비즈니스 로직, 화면 상태 참조 금지.
* 특정 Cubit 참조 금지 — `BlocProvider`/`BlocBuilder`/`context.read<XCubit>()` 금지. 데이터는 생성자 파라미터로, 이벤트는 콜백으로 받는다.
* 허용되는 관례:
  * 자기 자신을 닫는 `Navigator.of(context).pop()` (bottom sheet / dialog / 앱바 뒤로가기 기본 동작)
  * 제네릭 `Async<T>`를 **파라미터로 받는** 컴포넌트 (예: `AsyncAnimatedSwitcher`) — 값만 받을 뿐 구독은 호출부(Screen) 책임이다.

## 3. 의존성 규칙
* **허용:** Flutter SDK, `foundation/` 토큰, `lib/domain/entities/`의 순수 엔티티(`Async<T>`, `Era` 등).
* **금지:** `lib/data/`(Service·DTO·Dio), `lib/presentation/screens/`, `package:flutter_bloc`(컴포넌트가 Cubit을 알면 재사용 컴포넌트가 아니다), `package:go_router`(화면 이동은 Screen 소관 — 닫기는 `Navigator.pop`).

## 4. 새 컴포넌트 추가 전 체크
1. 기존 컴포넌트에 variant/파라미터 추가로 해결되는지 먼저 검토한다.
2. 특정 화면에서만 쓰이면 여기가 아니라 `screens/<feature>/widgets/`에 둔다.
3. **승격 위치:** 재사용 기준(Rule of Three → 루트 CLAUDE.md)을 충족하면 이곳으로 승격한다.

## 5. 토큰 규칙 (foundation/)
* 색상 상수 추가는 `app_colors.dart`에만 한다. 컴포넌트 파일 안 인라인 `Color(0xff...)` 금지.
* Figma의 새 색상은 유사 토큰으로 매핑하지 않고 새 상수로 추가한다.
* 팔레트 색상은 `primary50`~`primary900`처럼 단계별 네이밍을 따른다.
* 간격/라디우스는 매직넘버 대신 `AppSpacing`(4/8/12/16/20/24/32) / `AppRadius`(4/8/10/12/14/20/100) 토큰을 사용한다. 스케일에 없는 값은 일단 리터럴로 두고, 3회 이상 반복되면 토큰으로 승격한다.