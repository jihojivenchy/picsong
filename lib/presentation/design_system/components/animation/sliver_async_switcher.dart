import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:picsong/domain/entities/async_state/async_state.dart';

/// Async 상태에 따라 sliver를 페이드 전환으로 교체하는 스위처.
/// 호출부(Screen)가 BlocBuilder/select로 구독한 상태 값을 넘긴다.
class SliverAsyncSwitcher<T> extends HookWidget {
  const SliverAsyncSwitcher({
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
    // 애니메이션 컨트롤러 설정
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 400),
    );

    // 상태가 바뀔 때마다 애니메이션을 처음부터 다시 재생
    useEffect(() {
      controller.forward(from: 0.0);
      return null;
    }, [state]);

    // 현재 상태에 맞는 sliver 가져오기
    final Widget sliverChild = switch (state) {
      Loading<T>() => loading(),
      Failed<T>(:final Object error) => failed(error),
      Fetched<T>(:final T data) => fetched(data),
    };

    // Sliver 전용 페이드 애니메이션 적용
    return SliverFadeTransition(
      opacity: controller,
      sliver: sliverChild,
    );
  }
}
