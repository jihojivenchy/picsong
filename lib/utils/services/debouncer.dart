import 'dart:async';

/// void 콜백 타입 정의 - dart.ui의 VoidCallback을 import하지 않기 위해 별도 정의
/// A void callback, i.e. (){}, so we don't need to import e.g. `dart.ui`
/// just for the VoidCallback type definition.
typedef DebounceCallback = void Function();

/// 디바운스 작업을 나타내는 내부 클래스
/// 콜백 함수와 타이머를 함께 관리
class _DebounceOperation {
  DebounceCallback callback; // 콜백 함수
  Timer timer; // 타이머
  _DebounceOperation(this.callback, this.timer);
}

/// 메서드 호출 디바운싱을 처리하는 정적 클래스
/// 빈번한 호출을 제어하여 마지막 호출만 실행되도록 함
class Debouncer {
  /// 태그별 디바운스 작업을 저장하는 맵
  /// key: 디바운스 식별 태그, value: 디바운스 작업 객체
  static final Map<String, _DebounceOperation> _operations = {};

  /// 주어진 duration 후에 onExecute를 실행합니다.
  /// 같은 tag로 duration 내에 다시 호출되면, 이전 호출을 취소하고
  /// 새로운 duration 대기를 시작합니다.
  ///
  /// [tag]: 디바운스 작업을 식별하는 임의의 문자열
  /// [duration]: 실행 지연 시간 (Duration.zero면 즉시 실행)
  /// [onExecute]: 지연 후 실행할 콜백 함수
  ///
  static void debounce({
    required String tag,
    required Duration duration,
    required DebounceCallback onExecute,
  }) {
    // 지연 시간이 0이면 즉시 실행
    if (duration == Duration.zero) {
      _operations[tag]?.timer.cancel(); // 기존 타이머 취소
      _operations.remove(tag); // 작업 목록에서 제거
      onExecute(); // 콜백 실행
    } else {
      // 기존에 같은 태그의 작업이 있으면 취소
      _operations[tag]?.timer.cancel();

      // 새로운 타이머 설정
      _operations[tag] = _DebounceOperation(
        onExecute,
        Timer(
          duration,
          () {
            _operations[tag]?.timer.cancel();
            _operations.remove(tag);

            onExecute();
          },
        ),
      );
    }
  }

  /// 지정된 태그와 연결된 콜백을 즉시 실행합니다.
  /// 주의: 디바운스 타이머는 취소되지 않으므로, 콜백 실행 후 타이머도 취소하려면
  /// fire(tag) 호출 후 cancel(tag)를 별도로 호출해야 합니다.
  static void fire(String tag) {
    _operations[tag]?.callback();
  }

  /// 지정된 태그의 활성 디바운스 작업을 취소합니다.
  /// 타이머를 중단하고 작업 목록에서 제거합니다.
  static void cancel(String tag) {
    _operations[tag]?.timer.cancel();
    _operations.remove(tag);
  }

  /// 모든 활성 디바운서를 취소합니다.
  /// 등록된 모든 타이머를 중단하고 작업 목록을 비웁니다.
  static void cancelAll() {
    for (final operation in _operations.values) {
      operation.timer.cancel();
    }
    _operations.clear();
  }

  /// 활성 디바운서의 개수를 반환합니다.
  /// (아직 onExecute 메서드를 호출하지 않은 디바운서들의 수)
  static int count() {
    return _operations.length;
  }
}
