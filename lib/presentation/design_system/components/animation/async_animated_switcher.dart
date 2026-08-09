import 'package:flutter/material.dart';
import 'package:picsong/domain/entities/async_state/async_state.dart';

/// Async 상태에 따라 뷰를 페이드 전환으로 교체하는 스위처.
/// 호출부(Screen)가 BlocBuilder/select로 구독한 상태 값을 넘긴다.
class AsyncAnimatedSwitcher<T> extends StatelessWidget {
  const AsyncAnimatedSwitcher({
    super.key,
    required this.state,
    required this.fetched,
    required this.loading,
    required this.failed,
  });

  /// 표시할 비동기 상태
  final Async<T> state;
  final Widget Function(T data) fetched;
  final Widget Function() loading;
  final Widget Function(Object error) failed;

  @override
  Widget build(BuildContext context) {
    final Widget child = switch (state) {
      Loading<T>() => loading(),
      Failed<T>(:final Object error) => failed(error),
      Fetched<T>(:final T data) => fetched(data),
    };

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      child: child,
    );
  }
}
