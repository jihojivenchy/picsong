Claude Code가 이 프로젝트 작업 시 따르는 가이드.
이 파일은 **항상 로드**되므로 **계층 불문 공통 표준**만 담는다.
계층별 상세 규칙은 그 디렉터리의 CLAUDE.md가 담당한다(작업 시 자동 로드). → **§2 레이어 맵**.

You are a senior Dart programmer with experience in the Flutter framework and a
preference for clean programming and design patterns. Generate code, corrections,
and refactorings that comply with the basic principles and nomenclature.

## 1. 프로젝트 개요

- **프로젝트명:** 픽송(picsong) (Flutter 모바일 앱)
- **SDK:** Dart ^3.6.2 / Flutter 3.35.x (stable)
- **상태관리:** Bloc (flutter_bloc: ^9.1.1) — **Cubit 기본**, 상태는 Equatable 불변 State
- **라우팅:** go_router (^17.2.3) + go_router_builder codegen
- **UI 로컬 상태:** flutter_hooks (^0.21.2)
- **DI:** DI 컨테이너 없음 — Service는 사용처에서 직접 생성한다.
- **로컬DB:** Hive (hive_flutter)
- **로거:** talker (`AppLogger`)
- **토스트/로딩:** toastification (`AppToastService`) / flutter_easyloading

### 주요 명령어

```bash
# 분석 (에러/경고 0개 유지)
flutter analyze
```

## 2. 레이어 맵 (작업 → 규칙)

Hybrid Clean Architecture. **편집할 파일의 계층에 맞는 CLAUDE.md를 따른다.**

| 작업 | 위치 | 상세 규칙 |
|---|---|---|
| API·스토리지·SDK 연동, Service/DTO | `lib/data/` | `lib/data/CLAUDE.md` |
| 엔티티·순수 도메인 로직 | `lib/domain/` | `lib/domain/CLAUDE.md` |
| 화면·뷰모델(Cubit)·위젯 (MVVM+Bloc) | `lib/presentation/` | `lib/presentation/CLAUDE.md` |
| 디자인 토큰·재사용 컴포넌트 | `lib/presentation/design_system/` | `lib/presentation/design_system/CLAUDE.md` |
| 도메인 무관 범용 유틸 | `lib/utils/` | `lib/utils/CLAUDE.md` |

* 의존 방향: `presentation → domain ← data`. domain은 외부 프레임워크 의존 0.

## 3. 공통 코딩 표준 (계층 불문)

### 3-1. 타입 & 클린코드
* **Explicit Typing:** 모든 변수·함수(파라미터/반환)에 타입 명시. `dynamic` 금지.
* **Clean Code:** 함수 본문 안 불필요한 빈 줄 금지.

### 3-2. 함수/메서드 설계
* **SRP:** 함수는 단일 목적, 30줄 이하.
* **순수 함수 우선:** 출력은 입력만으로 결정. 부수효과·외부상태 의존 최소화. 입력 파라미터 mutate 금지(변경은 `copyWith`로 새 객체 반환).
* **Early Return:** `if-else` 중첩 대신 조기 반환. 복잡한 조건은 named 함수로 추출.
* **선언형:** `for`/`while` 대신 `map`/`where`/`fold` 등 고차함수.
* **표현식 스타일:** 2줄 이하 로직은 `=>`, 복잡하면 블록.
* **RO-RO:** 파라미터 2개 이상이면 named parameter, 복잡한 결과는 객체로 반환.
* **단일 추상화 수준:** 한 함수 안에서 추상화 레벨을 일관되게 유지.

### 3-3. 클래스
* 클래스 길이 200줄 이하. 상속보다 **합성(composition)**.
* 단일 책임 원칙을 따름

### 3-4. 순수함수 / 부수효과 분리
* 비즈니스 로직은 **side-effect shell + pure core**로 나눈다. 계산·변환·검증·필터·정렬은 순수 함수로, I/O·상태 반영(emit)·로깅·토스트는 shell에서 처리한다. (계층별 적용은 domain/presentation CLAUDE.md)

### 3-5. 문서화 & 멤버 정렬
* **주석 형식:** 프로퍼티는 1줄(`/// 설명`), 메서드는 3줄 블록(`///` → `/// 설명` → `///`). **What/Why** 중심(구현 설명 아님).
* **이름 우선:** 주석이 필요 없을 만큼 명확한 이름을 먼저 짓는다. 항상 직관적이고, 일관된 표현으로 네이밍
* **멤버 순서:** `생성자 주입 프로퍼티 → 생성자 → 상수 → 일반 프로퍼티 → 라이프사이클 → public 메서드 → private 메서드`. 생성자는 주입 프로퍼티 선언 바로 아래에 붙인다.
* **영역 구분:** 클래스 안에서 메서드 영역을 나눌 때는 `// MARK: - <영역명>` 주석을 사용한다(계층별 영역 구성은 각 CLAUDE.md).

### 3-6. Rule of Three
* 로직/UI가 **3회 이상** 중복될 때만 공통화한다. 2회면 중복(WET)을 허용해 섣부른 추상화를 피한다.
* 단일 호출처를 위한 추상화·인터페이스·파일 신설 금지. (승격 *위치*는 각 계층 CLAUDE.md)

## 4. 전역 금지 (어디서나)
* `print()` 직접 호출 금지 — `AppLogger`(`lib/utils/services/app_logger.dart`) 사용.

## 5. Pre-Submission Checklist
1. 구현이 사용자 요구를 정확히 반영하는가.
2. `flutter analyze` — error는 Stop hook이 자동 차단하므로 직접 돌릴 필요 없다. warning은 hook이 보고만 하니, 새로 생긴 warning은 임의 수정하지 말고 처리 방향을 사람과 정한다.
