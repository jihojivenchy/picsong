# lib/domain/ — Domain Layer Guardrails

순수 도메인 엔티티와 도메인 서비스의 자리. **외부 프레임워크 의존이 0이어야 한다.**

---

## 1. 디렉터리 책임

| 경로 | 책임 |
|---|---|
| `entities/` | 불변 도메인 객체. 비즈니스 규칙을 표현하지만 I/O는 하지 않음. |
| `services/` | 외부 시스템 없이 동작하는 순수 도메인 로직(달력 계산 등). I/O가 필요하면 `data/services/`에 둔다. |

## 2. 절대 import 금지

이 디렉터리의 모든 `.dart`는 다음을 **import해서는 안 된다**.

* `package:flutter/*`
* `package:flutter_bloc/*`, `package:bloc/*`, `package:equatable/*`
* `package:go_router/*`
* `package:dio/*`
* `package:hive/*`, `package:firebase_*`
* `lib/data/**`, `lib/presentation/**`, `lib/utils/**` 중 위 패키지에 의존하는 코드

순수 Dart 표준 라이브러리만 허용한다. 의존성이 필요하다면 그 엔티티는 도메인이 아니다 — `data/` 또는 `presentation/`으로 옮긴다.

## 3. 엔티티 규칙

* **불변:** 모든 필드 `final`. 생성자 인자는 named + `required`. 생성자는 `const` 가능하면 `const`.
* **`copyWith`:** 모든 변경은 `copyWith`로 새 객체 반환. 필드 직접 변경 금지.
* **초기/Mock 상태:** 필요 시 `static <T> get initialState => const <T>(...)` 또는 `static <T> get mock => ...` 패턴으로 노출.
* **검증:** 생성자/factory에서 자체 검증(Self-Contained Validation). 무효 상태가 생성될 수 없게.
* **`fromJson`/`toJson`:** 응답 파싱은 엔티티의 `factory <Entity>.fromJson`이 직접 담당한다. `toJson`은 **요청 엔티티에 한해** 둔다.
* **State Object:** 속성이 3개 이상이고 의미 단위가 묶이면 별도 엔티티로 추출.
* **프로퍼티 주석:** 모든 필드에 `///` 한 줄 설명을 붙인다.

### 3-1. Nullability & fromJson 폴백

필드는 기본적으로 **non-nullable**로 선언하고 `fromJson`에서 폴백 값으로 채운다.
`?`(null 허용)는 **부재 자체가 상태일 때만** 쓴다 — 플레이스홀더 기본 객체 없이 null 체크로 상태를 구분하기 위함.

| 대상 | 선언 / 폴백 | 이유 |
|---|---|---|
| ID (`int`) | `int` / `-1` | API 오류 시 `-1`을 보고 즉시 원인 식별(센티넬) |
| `String` (name 등) | `String` / `''` | `String?`이면 호출부에서 null + `isEmpty` 이중 체크가 생김 |
| 중첩 객체 · 하위 엔티티 | `?` 허용 | 부재가 곧 상태. 기본값 객체를 두면 상태 비교가 흐려짐 |

## 4. 도메인 서비스 규칙

* `domain/services/`의 public 메서드는 순수 함수로 작성한다.
  * 같은 입력이면 항상 같은 출력을 반환한다.
  * 입력 객체/리스트를 직접 변경하지 않고 새 객체/리스트를 반환한다.
  * 시간, 랜덤, 저장소, 네트워크, 플랫폼, Cubit, Logger, Toast를 직접 참조하지 않는다.
  * `DateTime.now()`가 필요하면 현재 시간을 파라미터로 받는다.
* 도메인 서비스는 상태를 보관하지 않는다. 모든 메서드는 입력값을 받아 결과값을 반환한다.
* 여러 값을 받아야 하면 named parameter를 사용한다.
* 검증/계산/필터링/정렬/변환 규칙은 도메인 서비스에 두고, I/O와 상태 반영은 `data/` 또는 `presentation/`에서 처리한다.

## 5. 필드명 규칙

API/UI 어휘와의 일관성을 위해 다음 치환 규칙을 따른다.

| 패턴 | 치환 | 예시 |
|---|---|---|
| 복합어 속 `Id` | `ID`로 표기 (단독 `id`는 그대로) | `userId` → `userID` |
| 복합어 속 `Url` | `URL`로 표기 (단독 `url`은 그대로) | `imageUrl` → `imageURL` |
| 복수형 (`...s`) | `...List`로 표기하고 타입은 `List<T>` | `users` → `userList: List<User>` |

## 6. enum 규칙

API 문자열 enum은 다음 3구성 패턴을 따른다.
* `displayText` — UI에 표시할 한국어 텍스트 (필요한 경우)
* `queryValue` — API 요청/응답에 사용하는 문자열 값
* `fromQueryValue` factory — null-safe 처리 포함

UI 노출이 없는 enum은 `queryValue` + `fromQueryValue`만으로 충분하다.

**UI 표현(색상·아이콘·로고)은 enum에 두지 않는다** — `displayText` 같은 표시 텍스트까지만 도메인이 갖고, 색상/아이콘 매핑은 `presentation/common/extensions/`의 extension으로 분리한다.

```dart
enum MeetingType {
  lover(displayText: '연인', queryValue: 'COUPLE'),
  mate(displayText: '메이트', queryValue: 'REGULAR');

  final String displayText;
  final String queryValue;

  const MeetingType({required this.displayText, required this.queryValue});

  factory MeetingType.fromQueryValue(String? value) {
    if (value == null) return MeetingType.lover;
    return MeetingType.values.firstWhere(
      (e) => e.queryValue == value,
      orElse: () => MeetingType.lover,
    );
  }
}
```

## 7. 명명 규칙

* 파일: snake_case (`sign_up_request.dart`).
* 클래스: PascalCase. 요청 객체는 `<Domain>Request`, 응답 도메인은 명사형(`Reservation`).
* `DTO` 접미사 금지 — 그건 data 계층 명명이다.

## 8. 금지 사항
* Bloc 의존(`Cubit`, `Bloc`, `Equatable`) 금지 — 화면 State는 presentation 소관이다. (`Async<T>`처럼 순수 Dart로만 쓴 상태 표현 엔티티는 허용.)
* `BuildContext`, `Widget` 참조 금지.
* 정적 상수 외에 전역 가변 상태 금지.
* 단일 호출처를 위한 추상화/인터페이스 신설 금지(Rule of Three → 루트 CLAUDE.md).
