
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get/get.dart';
import 'package:picsong/domain/entities/data_state/data_state.dart';

class SliverDsSwitcher<T> extends HookWidget {
  const SliverDsSwitcher({
    super.key,
    required this.state,
    required this.fetched,
    required this.loading,
    required this.failed,
    this.locationPermissionDenied,
  });

  final Rx<Ds<T>> state;
  final Widget Function(T data) fetched;
  final Widget Function() loading;
  final Widget Function(Object error) failed;

  /// 위치 권한 거부 상태 sliver (미지정 시 loading 폴백)
  final Widget Function()? locationPermissionDenied;

  @override
  Widget build(BuildContext context) {
    // 애니메이션 컨트롤러 설정
    final controller = useAnimationController(
      duration: const Duration(milliseconds: 400),
    );

    // 상태가 바뀔 때마다 애니메이션을 다시 실행
    useEffect(() {
      // 상태가 변경될 때마다 애니메이션을 처음부터 다시 재생
      controller.forward(from: 0.0);
      return null;
    }, [state.value]);

    return Obx(() {
      // 현재 상태에 맞는 위젯을 가져오기
      final sliverChild = state.value.onState(
        fetched: (data) => fetched(data),
        loading: () => loading(),
        failed: (error) => failed(error),
        locationPermissionDenied: locationPermissionDenied,
      );

      // Sliver 전용 페이드 애니메이션 적용
      return SliverFadeTransition(
        opacity: controller,
        sliver: sliverChild,
      );
    });
  }
}
