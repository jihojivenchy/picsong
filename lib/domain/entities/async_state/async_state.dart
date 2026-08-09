/// 비동기 조회 상태 — 화면 State의 필드로 사용한다.
///
/// UI는 switch 패턴 매칭으로 소비한다:
/// ```dart
/// switch (state.notificationList) {
///   Loading() => const LoadingView(),
///   Failed(:final error) => ErrorView(error: error),
///   Fetched(:final data) => NotificationListView(list: data),
/// }
/// ```
sealed class Async<T> {
  const Async();

  /// 조회 성공 데이터 (성공 상태가 아니면 null)
  T? get valueOrNull => switch (this) {
        Fetched<T>(:final T data) => data,
        _ => null,
      };
}

/// 초기/재조회 로딩
final class Loading<T> extends Async<T> {
  const Loading();
}

/// 조회 성공
final class Fetched<T> extends Async<T> {
  const Fetched(this.data);

  /// 조회된 데이터
  final T data;
}

/// 조회 실패
final class Failed<T> extends Async<T> {
  const Failed(this.error);

  /// 실패 원인
  final Object error;
}
