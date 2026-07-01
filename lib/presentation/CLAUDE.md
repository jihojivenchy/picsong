# lib/presentation/ — Presentation Layer Guardrails

화면, 뷰모델, 디자인 시스템을 포함하는 MVVM + GetX 계층입니다.
**편집 중인 파일의 역할에 맞는 섹션을 적용합니다:** `*_screen.dart` → §2, `*_controller.dart`·`viewmodels/` → §3, `widgets/` 및 기타 위젯 파일 → §4.

---

## 1. 공통

### 디렉터리 책임

| 경로 | 책임 |
|---|---|
| `screens/` | 피처별 화면. `screen.dart` + `controller.dart` + `viewmodels/` + `widgets/` 구성. |
| `design_system/` | 디자인 토큰(`foundation/`) + 재사용 컴포넌트(`components/`). **작성/수정 규칙은 `design_system/CLAUDE.md`를 따른다.** |
| `common/` | `base/`(BaseScreen), `extensions/`, `mixins/`, `services/`(AppSize·Dialog·Toast·이미지 피커·딥링크 등 UI 부수 서비스), `text_formatters/`, `widgets/` |
| `global/` | 앱 전역 싱글톤 매니저(`UserManager`·`PaymentSessionManager`·`LocationManager`). 화면 수명과 무관한 앱 전역 상태. |
| `hooks/` | 재사용 커스텀 `flutter_hooks`(`useAutoHideBar` 등) — 위젯 로컬 상태/효과를 훅으로 추출. |

### 화면 폴더 컨벤션

```
screens/<feature>/
├── <feature>_screen.dart        # BaseScreen 상속, DI + UI
├── <feature>_controller.dart    # GetxController (단일이면 루트에)
├── viewmodels/                  # 다수의 컨트롤러/상태 클래스가 있을 때
└── widgets/                     # 해당 화면 전용 위젯
```

* 컨트롤러가 1개면 루트, 여러 개면 `viewmodels/`로 분리.

## 2. Screen 규칙
* `BaseScreen<T>`(`lib/presentation/common/base/base_screen.dart`)을 상속한다. `T`는 컨트롤러 타입.
* 컨트롤러가 없는 정적 화면은 제네릭 없이 `BaseScreen`만 상속한다. 
* 데이터는 생성자 파라미터로 받는다.
* 비즈니스 로직 금지. 이벤트는 `viewModel`의 메서드 호출로 위임.
* 상태 읽기는 `viewModel.request.value.xxx`처럼 **Screen에서 직접 접근**한다.
* **Obx 최소 범위:** 변경되는 위젯만 감싼다. 화면 전체 `Obx` 금지.
* `buildBody`에 거대한 UI 트리 금지 — 섹션은 `_buildXxx()` 또는 `widgets/`의 별도 위젯으로 분리. 위젯 트리 5단계 초과 중첩 금지.

## 3. ViewModel(Controller) 규칙
* 비즈니스 로직을 담당합니다.
* `GetxController` 상속. 명명: `<Feature>Controller`, 파일명: `<feature>_controller.dart`.
* 필요한 파라미터는 init 패턴으로 주입받습니다. Get.arguments 사용하지 마세요.
* **단순 위임 게터 금지:** `bool get hasX => state.value.x != null` 같은 게터를 두지 않는다. 계산 로직이 있는 getter만 허용.
* 메서드는 가능한 한 **side-effect shell + pure core** 구조로 작성한다.
  * public 메서드/UI 이벤트 메서드는 Service 호출, 로딩 처리, 상태 반영만 담당한다.
  * 상태 계산, 리스트 병합, 요청 객체 변환, 검증 로직은 private 순수 함수로 분리한다.
  * 순수 함수는 `Rx`, `Get`, `BuildContext`, Service, Toast, Logger를 참조하지 않는다.
  * 순수 함수는 입력 파라미터만으로 결과를 반환하고, 입력 객체/리스트를 직접 mutate하지 않는다.
* 상태 변경은 `_setXxxState()` 또는 `_updateXxx()` 같은 전용 메서드로 중앙집중화한다.
* **UI 전용 상태를 두지 않는다.** 다음은 위젯 로컬(`flutter_hooks`의 `useState` 등)에서 관리:
  * 확장/접힘(`isExpanded`), 표시/숨김 토글(`isShow`, `isVisible`)
  * 배너/캐러셀의 현재 인덱스
  * 애니메이션 컨트롤러
* 단, 페이징 트리거처럼 비즈니스 동작과 연결된 `ScrollController`는 Controller에 둘 수 있다. 단순 시각 효과용 `PageController`/애니메이션 컨트롤러는 위젯 로컬에서 관리한다.
* **앱 전역 상태**(로그인 사용자·결제 세션·위치 등)는 특정 Controller가 아니라 `global/`의 매니저에 둔다.

### 비동기 상태 — `Ds<T>` 패턴
비동기 조회 상태는 `Ds<T>`(`lib/domain/entities/data_state/data_state.dart`)를 사용한다.
* `Loading()` — 초기/재조회 로딩
* `Fetched(data)` — 조회 성공
* `Failed(error)` — 조회 실패

```dart
final Rx<Ds<NotificationList>> state = Rx<Ds<NotificationList>>(Loading());
```

| 화면 유형 | 패턴 |
|---|---|
| List / Detail / Update / TabbedList / HomeScroll (조회 우선) | `Rx<Ds<T>>(Loading())` |
| Create / StepCreate (조회 없이 입력만) | `Rx<T>(T.initialState)` 직접 사용 |

## 4. Widget(View) 규칙

* 표시 전용. Controller 직접 참조 금지 — 데이터는 파라미터, 이벤트는 콜백으로 받는다.
* **70줄 이상의 위젯**(또는 `_buildXxx` 메서드)은 같은 화면 디렉터리의 `widgets/`에 별도 `.dart` 파일로 추출한다.
* **Single Responsibility per File:** 한 파일에 `StatelessWidget`/`StatefulWidget`을 2개 이상 선언하지 않는다.
* 화면 내부 하위 위젯이 필요하면 같은 파일에 private widget으로 두지 않고, 해당 화면의 `widgets/` 디렉터리로 분리한다.
* 특정 섹션에 속한 위젯이 여러 개면 `widgets/<section>/` 하위 디렉터리로 묶어 범위를 드러낸다.
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
| 간격 | `Gap` (`design_system/components/layout/`) |
| 간격/라디우스 값 | `AppSpacing` / `AppRadius` (`design_system/foundation/`) — 매직넘버 대신 사용 |
