import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:picsong/domain/entities/data_state/data_state.dart';

class DsAnimatedSwitcher<T> extends StatelessWidget {
  const DsAnimatedSwitcher({
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

  /// 위치 권한 거부 상태 뷰 (미지정 시 loading 폴백)
  final Widget Function()? locationPermissionDenied;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final child = state.value.onState(
        fetched: (data) => fetched(data),
        loading: () => loading(),
        failed: (error) => failed(error),
        locationPermissionDenied: locationPermissionDenied,
      );

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
    });
  }
}
