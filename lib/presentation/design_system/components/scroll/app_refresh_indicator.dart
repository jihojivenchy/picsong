import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';

class AppRefreshIndicator extends HookWidget {
  const AppRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  /// 새로고침 콜백
  final Future<void> Function() onRefresh;

  /// 스크롤 가능한 자식 위젯
  final Widget child;

  /// 인디케이터가 멈출 위치 (상단으로부터)
  static const double _indicatorTop = 16.0;

  /// 인디케이터 크기
  static const double _indicatorSize = 28.0;

  /// 인디케이터 stroke 두께
  static const double _strokeWidth = 2.8;

  /// 콘텐츠가 밀려 내려갈 최대 거리
  static const double _maxContentOffset = 60.0;

  /// 로딩 중 회전 한 사이클(ms)
  static const int _spinDurationMs = 900;

  @override
  Widget build(BuildContext context) {
    // 로딩 중 회전용 컨트롤러
    final spinController = useAnimationController(
      duration: const Duration(milliseconds: _spinDurationMs),
    );

    return CustomRefreshIndicator(
      onRefresh: onRefresh,
      onStateChanged: (change) {
        if (change.didChange(to: IndicatorState.loading)) {
          spinController.repeat();
        } else if (change.didChange(from: IndicatorState.loading)) {
          spinController.stop();
          spinController.value = 0.0;
        }
      },
      builder: (context, child, controller) {
        return AnimatedBuilder(
          animation: Listenable.merge([controller, spinController]),
          builder: (context, _) {
            final dragValue = controller.value.clamp(0.0, 1.25);
            final isLoading = controller.state == IndicatorState.loading;
            // 당김 진행도(0~1)에 따라 0.7 → 1.0 스케일
            final scale = 0.7 + 0.3 * controller.value.clamp(0.0, 1.0);
            final opacity = controller.value.clamp(0.0, 1.0);

            return Stack(
              children: [
                // 콘텐츠를 당김량에 따라 아래로 이동
                Transform.translate(
                  offset: Offset(0, dragValue * _maxContentOffset),
                  child: child,
                ),
                // 회전 인디케이터
                Positioned(
                  top: _indicatorTop,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Opacity(
                      opacity: isLoading ? 1.0 : opacity,
                      child: Transform.scale(
                        scale: isLoading ? 1.0 : scale,
                        child: SizedBox(
                          width: _indicatorSize,
                          height: _indicatorSize,
                          child: CircularProgressIndicator(
                            strokeWidth: _strokeWidth,
                            strokeCap: StrokeCap.round,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                            backgroundColor: AppColors.primary.withValues(
                              alpha: 0.15,
                            ),
                            // 당김 중에는 진행도 표시, 로딩 중에는 회전
                            value: isLoading
                                ? null
                                : controller.value.clamp(0.0, 1.0),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
      child: child,
    );
  }
}
