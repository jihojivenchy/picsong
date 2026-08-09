# lib/presentation/ — Presentation Layer Guardrails

화면, 뷰모델(Cubit), 라우팅, 디자인 시스템을 포함하는 MVVM + Bloc 계층입니다.
**편집 중인 파일의 역할에 맞는 섹션을 적용합니다:** `*_screen.dart` → §2, `viewmodel/`의 `*_cubit.dart`·`*_state.dart` → §3, `widgets/` 및 기타 위젯 파일 → §4. `router/` 편집 시에는 `router/CLAUDE.md`를 따릅니다.

---

## 1. 공통

### 디렉터리 책임

| 경로 | 책임 |
|---|---|
| `screens/` | 피처별 화면. `screen.dart` + `viewmodel/`(cubit·state) + `widgets/` 구성. |
| `router/` | 앱 라우터(go_router + go_router_builder codegen). **라우트 선언·전달·전환 규칙은 `router/CLAUDE.md`를 따른다.** |
| `design_system/` | 디자인 토큰(`foundation/`) + 재사용 컴포넌트(`components/`). **작성/수정 규칙은 `design_system/CLAUDE.md`를 따른다.** |
| `common/` | `base/`(BaseScreen·BaseCubitScreen·BaseView·BaseCubitView), `extensions/`, `services/`(AppSize·Dialog·Toast 등 UI 부수 서비스) |
| `global/` | 앱 전역 싱글톤 매니저. 화면 수명과 무관한 앱 전역 상태 — `ChangeNotifier` 싱글톤으로 둔다. |
| `hooks/` | 재사용 커스텀 `flutter_hooks`(`useAutoHideBar` 등) — 위젯 로컬 상태/효과를 훅으로 추출. |

### 화면 폴더 컨벤션

```
screens/<feature>/
├── <feature>_screen.dart        # BaseCubitScreen 상속, DI + UI
├── viewmodel/
│   ├── <feature>_cubit.dart     # Cubit — part '<feature>_state.dart' 선언
│   └── <feature>_state.dart     # part of — 화면 상태 (불변 + copyWith)
└── widgets/                     # 해당 화면 전용 위젯
```

* Cubit과 State는 **항상 화면 폴더의 `viewmodel/` 하위에 함께** 둔다. State 파일은 항상 자신의 Cubit 파일에 `part`로 종속시킨다.

## 2. Screen 규칙
* `BaseCubitScreen<T>`(`lib/presentation/common/base/base_cubit_screen.dart`)을 상속한다. `T`는 Cubit 타입.
* 뷰모델이 없는 정적 화면은 `BaseScreen`(`lib/presentation/common/base/base_screen.dart`)을 상속한다.
* **DI는 `createViewModel` 팩토리가 담당한다.** 초기 조회는 `Cubit(...)..fetchXxx()` 캐스케이드로 트리거한다. 별도 put/delete 코드를 두지 않는다 — 화면이 트리에서 빠지면 Cubit은 자동 close된다.
* 데이터는 생성자 파라미터로 받는다. 화면 생성자 파라미터를 `createViewModel`에서 Cubit 생성자로 전달한다(init 주입 패턴).
* 비즈니스 로직 금지. 이벤트는 `viewModel(context).method()` 호출로 위임.
* **리빌드 최소 범위:** 상태 구독은 `BlocBuilder` + `buildWhen` 또는 `context.select`로 **변경되는 위젯만** 감싼다. 화면 전체를 하나의 `BlocBuilder`로 감싸지 않는다.
* 비동기 슬롯 렌더링은 sealed 패턴 매칭(`switch (state.xxx) { Loading() => ..., Failed(...) => ..., Fetched(...) => ... }`) 또는 `AsyncAnimatedSwitcher`를 사용한다.
* `buildBody`에 거대한 UI 트리 금지 — 섹션은 `_buildXxx()` 또는 `widgets/`의 별도 위젯으로 분리. 위젯 트리 5단계 초과 중첩 금지.

### 2-1. 라우팅 · Dialog · BottomSheet 소유권

* **화면 이동은 Screen이 담당한다.** 콜백 안에서 인라인 호출한다. (형식은 `router/CLAUDE.md` — `SomeRoute(param).push(context)`, `context.pop()`, `const HomeRoute().go(context)`.)
  * `push` = 스택에 쌓기(상세 진입), `go` = 스택 교체(온보딩 완료 → 메인 등 플로우 전환).
* **Dialog/BottomSheet의 `show` 호출도 Screen이 담당한다.** ViewModel은 데이터와 콜백만 제공한다.
* `void goToXxx() => SomeRoute().push(...)` 같은 **순수 라우팅/표시 래퍼 메서드 금지** — Screen에도 ViewModel에도 만들지 않는다. (여러 곳에서 재사용되는 시트 표시 등 실질 로직이 있는 경우만 메서드로 둔다.)
* **ViewModel(Cubit)에서 라우팅 금지 — 예외 없음.** 처리 결과에 따라 분기해야 하면 Cubit 메서드가 **결과를 반환**하고 Screen 콜백이 분기한다. `await` 이후 context 사용 전 `if (!context.mounted) return;` 가드 필수.
  ```dart
  onTap: () async {
    final bool isReady = await viewModel(context).prepareRound();
    if (!context.mounted) return;
    if (isReady) const QuestionRoute().push(context);
  },
  ```

### 2-2. Screen 메서드 배치 순서

1. 생성자 주입 프로퍼티 + 생성자
2. `createViewModel`
3. 라이프사이클: `onInit` → `onDispose` → `buildAppBar` → `buildBody`
4. `_buildXxx` 위젯 메서드 — **UI 상단에서 하단 순서대로**
5. `// MARK: - Bottom Sheets & Dialogs` — 시트/다이얼로그 표시 메서드
6. `// MARK: - Helpers` — 그 외 보조 메서드
7. 파일 최하단 — 레이아웃 상수 클래스 `_Metrics`

* 영역 구분은 `// MARK: - <영역명>` 주석. 해당 영역이 없으면 MARK도 만들지 않는다.
* **레이아웃 상수:** 화면 로컬 수치 상수가 3개 이상이면 파일 하단 `abstract final class _Metrics`로 모은다(상수마다 `///` 한 줄 주석). 1~2개면 클래스 상단 `static const`로 둔다.

## 3. ViewModel(Cubit) 규칙
* 비즈니스 로직을 담당합니다.
* **Cubit 기본:** `Cubit<State>` 상속. 명명: `<Feature>Cubit`, 파일명: `<feature>_cubit.dart` + `part '<feature>_state.dart'`.
* **Bloc(이벤트) 예외:** 검색 debounce·페이징 droppable처럼 **EventTransformer가 실제 필요한 화면만** `Bloc<Event, State>`를 쓴다. 그 외는 Cubit.
* 필요한 파라미터는 생성자로 주입받습니다. 화면 생성자 파라미터를 Cubit 생성자로 전달한다.
* **단순 위임 게터 금지:** `bool get hasX => state.x != null` 같은 게터를 두지 않는다. 계산 로직이 있는 getter만 허용.
* 메서드는 가능한 한 **side-effect shell + pure core** 구조로 작성한다.
  * public 메서드/UI 이벤트 메서드는 Service 호출, 로딩 처리, `emit`만 담당한다.
  * 상태 계산, 리스트 병합, 요청 객체 변환, 검증 로직은 private 순수 함수로 분리한다.
  * 순수 함수는 `emit`, `BuildContext`, Service, Toast, Logger를 참조하지 않는다.
  * 순수 함수는 입력 파라미터만으로 결과를 반환하고, 입력 객체/리스트를 직접 mutate하지 않는다.
* **상태 변경은 `emit(state.copyWith(...))`로만 한다.** State 필드 직접 변경 금지. 연속 emit이 필요한 복잡한 전이는 `_setXxxState()` 전용 메서드로 중앙집중화한다.
* **Toast·EasyLoading은 Cubit에서 직접 호출해도 된다** — `AppToastService`/`EasyLoading`은 context-free 서비스다. Dialog/BottomSheet/라우팅은 §2-1 소유권 규칙대로 Screen 소관.
* **UI 전용 상태를 State에 두지 않는다.** 다음은 위젯 로컬(`flutter_hooks`의 `useState` 등)에서 관리:
  * 확장/접힘(`isExpanded`), 표시/숨김 토글(`isShow`, `isVisible`)
  * 배너/캐러셀의 현재 인덱스
  * 애니메이션 컨트롤러
* 단, 페이징 트리거처럼 비즈니스 동작과 연결된 `ScrollController`/`PageController`는 Cubit이 보유할 수 있다. 이 경우 `close()` 오버라이드에서 dispose한다. 단순 시각 효과용 컨트롤러는 위젯 로컬에서 관리한다.
* **앱 전역 상태**는 특정 Cubit이 아니라 `global/`의 매니저에 둔다.
* **멤버 순서:** 주입 파라미터 프로퍼티 → 생성자(주입 프로퍼티 바로 아래) → 상수 → 서비스 객체 → 일반 프로퍼티 → 라이프사이클(`close`) → public 메서드 → private 헬퍼/순수 함수(최하단).
* **public 메서드는 화면 작업 흐름 순서대로 배치한다:** 조회(`fetch`) → 수정/토글(`update`·`toggle`) → 최종 제출(`request`·`submit`). 영역이 나뉘면 `// MARK: - <영역명>` 주석으로 구분한다.
* **복수 조회 메서드 명명:** 목록 조회는 `fetch<Xxx>List()` — 엔티티의 `...List` 필드명 규칙과 표현을 맞춘다.
* **조회 실패 처리 표준:** `catch`에서 ① `AppLogger.log`, ② `emit(... Failed(error))` 상태 반영, ③ `AppToastService.show('<대상> 조회 중 오류 안내')` 순서로 처리한다.

### 3-1. State 클래스 규칙

* 화면당 **단일 불변 State 클래스**: `final class <Feature>State extends Equatable`, 전 필드 `final`, `const` 생성자 + 기본값, 수기 `copyWith`, `props`에 전 필드 나열.
* State 파일은 Cubit 파일의 `part`로 둔다(`part of '<feature>_cubit.dart';`).

### 3-2. 비동기 상태 — `Async<T>` 패턴

비동기 조회 상태는 `Async<T>`(`lib/domain/entities/async_state/async_state.dart`)를 State 필드로 사용한다.
* `Loading()` — 초기/재조회 로딩
* `Fetched(data)` — 조회 성공
* `Failed(error)` — 조회 실패

```dart
// State
final Async<List<Song>> songList; // 기본값 const Loading()

// Cubit
emit(state.copyWith(songList: Fetched(result)));

// Screen — sealed라 분기 누락은 컴파일 에러
switch (state.songList) {
  Loading() => const LoadingView(),
  Failed(:final error) => ErrorView(error: error),
  Fetched(:final data) => SongListView(list: data),
}
```

| 화면 유형 | 패턴 |
|---|---|
| List / Detail / Update / TabbedList / HomeScroll (조회 우선) | State에 `Async<T>` 필드 (기본값 `const Loading()`) |
| Create / StepCreate (조회 없이 입력만) | State가 요청 엔티티를 직접 보유 (`request: T.initialState`) |

* `copyWith`는 안 바뀐 필드의 인스턴스를 재사용하므로, `buildWhen`/`select`의 슬롯 비교(identity)만으로 최소 리빌드가 성립한다 — 엔티티에 동등성 구현을 요구하지 않는다.

## 4. Widget(View) 규칙

* 표시 전용. Cubit 직접 참조 금지 — `BlocBuilder`/`context.read` 사용 금지. 데이터는 파라미터, 이벤트는 콜백으로 받는다. (상태 구독은 Screen의 `buildBody`/`_buildXxx`에서만.)
* **70줄 이상의 위젯**(또는 `_buildXxx` 메서드)은 같은 화면 디렉터리의 `widgets/`에 별도 `.dart` 파일로 추출한다.
* **Single Responsibility per File:** 한 파일에 `StatelessWidget`/`StatefulWidget`을 2개 이상 선언하지 않는다.
* 화면 내부 하위 위젯이 필요하면 같은 파일에 private widget으로 두지 않고, 해당 화면의 `widgets/` 디렉터리로 분리한다.
* 특정 섹션에 속한 위젯이 여러 개면 `widgets/<section>/` 하위 디렉터리로 묶어 범위를 드러낸다.
* **리스트는 ListView 우선:** 반복 아이템 목록은 `Column`/`Row` + `map(...).toList()`가 아니라 `ListView`/`ListView.separated`(sliver 컨텍스트면 `SliverList`)로 구성한다. 부모가 스크롤을 소유하면 `shrinkWrap: true` + `NeverScrollableScrollPhysics`. `Column`/`Row`는 개수가 고정된 소수 요소 배치처럼 꼭 필요한 경우에만 쓴다(칩 플로우는 `Wrap`). `asMap().entries.expand(...)` 식 컬렉션 곡예 금지.
* **날짜 표시:** 표시 포맷 변환은 위젯에서 `lib/utils/extensions/string_extension.dart`의 extension(`toFormat` 등)을 우선 활용한다. 필요한 포맷이 없으면 그 파일에 추가한다. 엔티티에 포맷 로직을 요구하지 않는다.
* 화면 전용 위젯은 해당 `screens/<feature>/widgets/`에 둔다.
* **승격 위치:** 재사용 컴포넌트는 `design_system/components/`로 승격(규칙은 `design_system/CLAUDE.md`). 승격 기준은 루트 CLAUDE.md의 Rule of Three.

## 5. 디자인 시스템 사용 규칙

* 색상은 **`design_system/foundation/`의 토큰만** 사용. 인라인 `Color(0xff...)` 금지.
* Figma에서 새 색상이 등장하면 **유사 토큰으로 매핑하지 않고** 새 상수를 추가한다(추가 위치는 `design_system/CLAUDE.md`).
* 텍스트/버튼/입력 등 기본 컴포넌트는 `design_system/components/`의 것을 사용한다. 비슷한 위젯을 새로 만들기 전 기존 컴포넌트의 variant 추가 가능성을 먼저 검토.
* 도메인 enum의 색상/아이콘 매핑은 `common/extensions/`의 extension으로 둔다.

| 역할 | 컴포넌트 |
|---|---|
| 텍스트 | `AppText` (`design_system/components/text/`) |
| 버튼 | `AppButton` (`design_system/components/button/`) |
| 입력 필드 | `AppTextField` (`design_system/components/text_field/`) |
| 앱바 | `DefaultAppBar` (`design_system/components/bar/`) |
| 다이얼로그 | `AppDialog` (`design_system/components/dialog/`) + `DialogService` (`common/services/`) |
| 토스트 | `AppToastService` (`common/services/`) |
| 비동기 상태 전환 | `AsyncAnimatedSwitcher` / `SliverAsyncSwitcher` (`design_system/components/animation/`) |
| 간격 | `Gap` (`design_system/components/layout/`) |
| 간격/라디우스 값 | `AppSpacing` / `AppRadius` (`design_system/foundation/`) — 매직넘버 대신 사용 |
| 네트워크 이미지 | `CachedImage` (`design_system/components/image/`) |
