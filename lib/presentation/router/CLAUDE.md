# lib/presentation/router/ — Routing Guardrails

앱 라우터(go_router + go_router_builder codegen)를 정의하는 계층입니다.
이 문서는 **`router/` 하위 파일을 편집할 때의 규칙**입니다. 화면에서 이동을 *호출하는* 소유권 규칙은 `lib/presentation/CLAUDE.md`의 "라우팅 · Dialog · BottomSheet 소유권"을 따릅니다.

---

## 1. 파일 구성

| 경로 | 책임 |
|---|---|
| `router.dart` | `appRouter`(GoRouter)와 라우트 클래스 전체. 화면 라우트는 모두 이 파일에 모은다. |
| `router.g.dart` | go_router_builder codegen 산출물. 직접 수정 금지 — `router.dart` 수정 후 재생성한다. |
| `pages/` | 커스텀 전환 `Page` (`lib/presentation/router/pages/fade_transition_page.dart`). |

## 2. 라우트 선언 형식

* 모든 화면은 `lib/presentation/router/router.dart`에 **TypedGoRoute 클래스**로 선언한다. 수정 후 `dart run build_runner build`로 `router.g.dart`를 재생성한다.
* **라우트 클래스 형식:** `static const path/name` 상수 + 타입 있는 생성자 파라미터 + `with $<Route>` mixin(go_router_builder 4.x — 언더스코어 없는 `$` 접두).
  ```dart
  class ModelDownloadRoute extends GoRouteData with $ModelDownloadRoute {
    const ModelDownloadRoute({required this.era});

    static const String path = 'model-download';
    static const String name = 'model-download';

    /// 다운로드 후 진입할 시대 — `Era.queryValue` (query parameter)
    final String era;

    @override
    Widget build(BuildContext context, GoRouterState state) =>
        ModelDownloadScreen(era: Era.fromQueryValue(era));
  }
  ```
* `path`/`name`은 **kebab-case**로 통일한다.
* **`@TypedGoRoute` 애너테이션은 최상위 라우트에만 붙인다.** 부모 위에만 쌓이는 화면은 부모의 `routes:` 목록에 `TypedGoRoute<자식Route>(...)`으로 중첩 선언한다 — 홈 자식 라우트들이 그렇다(`go`로 진입해도 홈이 스택 바닥에 남아 뒤로가기가 항상 홈으로 떨어진다).
* **라우트는 플로우 구역으로 묶는다** — `// MARK: - <구역명>` 주석으로 구분한다(부트스트랩 / 홈 / 게임 플로우 / 공용 오버레이 / 진단(임시)).

## 3. 객체 전달 규약

* 라우트 클래스의 선언 필드는 **path/query 파라미터만** 둔다. codegen `$extra` 필드 금지(부모/자식 라우트 덮어쓰기 이슈 — flutter/flutter#106121).
* 객체는 `context.push(SomeRoute().location, extra: object)`로 싣고, 라우트 `build`에서 `state.extra`를 수동 캐스트해 화면 생성자로 넘긴다.
* **extra로 넘길 인자는 `<Route>Args` typedef(record)로 묶는다.** 해당 라우트 클래스 **바로 위**에 선언하고 `/// <설명> (extra)` 한 줄 주석을 단다.
  ```dart
  /// 라운드 결과 요약 (extra)
  typedef RoundResultArgs = ({Era era, List<QuestionResult> resultList});
  ```
* **딥링크 대상 라우트는 extra 없이 path/query만으로도 동작해야 한다** (extra 유무 이중 경로).
* **라우트 `build`가 "문자열 → 타입" 변환의 유일한 장소다.** 화면은 타입 있는 생성자만 노출하고 `GoRouterState`를 모른다.

## 4. 전환

* 스택이 교체되는 라우트(스플래시·온보딩·메인)는 `FadeTransitionPage`(`lib/presentation/router/pages/`)로 `buildPage`를 구성한다.
* 일반 push는 기본 전환. 단, 뒤 화면이 비쳐야 하는 오버레이는 `CustomTransitionPage`(`opaque: false`)로 `buildPage`를 직접 구성한다.

## 5. 게이트 · 플로우 정책

* **redirect 게이트는 두지 않는다.** 부트스트랩 → 온보딩/홈 판정은 스플래시 화면의 `BlocListener`가 하고, 라우터는 `redirect`/`refreshListenable` 없이 화면 주도 이동만 받는다. 전역 게이트가 필요해지면 그때 `appRouter`의 `redirect` 한 곳에서만 관리한다.
* 다단계 플로우에서 화면 간 Cubit을 공유해야 하면 `ShellRoute` + `BlocProvider`로 플로우 전체를 감싼다(단건 전달은 extra·생성자 주입이 우선).
