# lib/data/ — Data Layer Guardrails

API/스토리지/외부 SDK 등 외부 시스템과의 통신을 책임지는 계층입니다.
이 디렉터리의 파일을 작성·수정할 때 아래 규칙을 따릅니다.

---

## 1. 디렉터리 책임

| 경로 | 책임 | 금지 |
|---|---|---|
| `dio/` | Dio 설정, 인터셉터, 공통 옵션, 커스텀 예외 정의 | 비즈니스 로직 |
| `services/` | 도메인별 작업(네트워크/SDK/스토리지 호출의 집합) | UI 의존(GetX/Widget) |
| `database/` | Hive 등 로컬 DB 어댑터/박스 정의 | UI 의존 |

## 2. DTO 규칙
* **기본:** 도메인 관련 API 응답은 도메인 엔티티의 `factory <Entity>.fromJson(...)`으로 직접 파싱한다. 별도 DTO를 만들지 않는다.
* **fromJson 작성:** null/누락 필드는 안전 기본값으로 처리한다. 표시용 포맷팅(날짜 문자열 등)은 넣지 않고 raw 값을 보관한다 — 표시 포맷은 presentation 책임.
* **DTO는 두지 않는다.** 응답이 도메인과 무관하고 data 계층 안에서만 쓰이다 사라지는 경우(예: 토큰 응답 → 키체인에 바로 저장)가 생기면, 그때 전용 디렉터리와 이 규칙을 함께 되살린다. 현재 프로젝트에는 해당 사례가 없다.

## 3. Service 규칙

* **위치/명명:** `lib/data/services/<domain>/<domain>_service.dart`, 클래스 `<Domain>Service` (`AuthService`, `ReservationService`).
* **DI:** 내부 의존성은 `_dioService`, `_storage`처럼 private final로 보유. 클래스 외부 노출 금지.
* **반환 타입:** 가급적 **도메인 엔티티**(`lib/domain/entities`)를 반환. 전송 전용 DTO(토큰 등)는 예외. presentation 객체는 절대 반환하지 않음.
* **입력:** 도메인 엔티티 또는 named primitive. UI 객체(Controller/State) 직접 수신 금지.
* **새 Service 신설 전 점검:** 동일 도메인 Service가 이미 존재하면 **기존 Service에 메서드 추가/교체**가 우선. mock 메서드가 있다면 그것을 실제 구현으로 교체.
* **메서드 길이:** SRP 준수, 30줄 초과 시 분리.
* **모델 정의 금지:** Service 파일 내부에 엔티티 클래스를 정의하지 않는다. 모델은 `lib/domain/entities/`에 둔다.

### 3-1. 주석 형식

| 대상 | 형식 |
|---|---|
| 프로퍼티 | 1줄 (`/// 설명`) |
| 메서드 | 3줄 (`///` → `/// 설명` → `///`) |

```dart
/// Dio 서비스
final DioService _dioService = DioService();

///
/// 구글 로그인 진행
///
Future<SignInResponseDTO> signInWithGoogle() async { ... }
```

## 4. 예외 처리

* **사용 예외:** `lib/data/dio/error/error_exception_type.dart`의 커스텀 예외(`ServerException` 등)만 사용.
* **예시:** `throw ServerException('네이버 토큰 발급 실패');`
* **금지:** `throw Exception(...)` 같은 일반 예외, 빈 catch, 무의미한 try/catch 래핑.
* **재던지기:** context를 추가하지 않는 catch는 두지 않는다.

## 5. 금지 사항 (Data 계층 한정)

* GetX(`Get.find`, `Obx`, `RxString` 등) 사용 금지.
* `BuildContext`, `Widget`, `Navigator` 의존 금지.
* DTO/엔티티에서 `lib/presentation/**` import 금지.
* 새 Service의 단일 메서드를 위해 별도 파일 생성 금지(Rule of Three → 루트 CLAUDE.md).
