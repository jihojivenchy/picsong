import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';

/// 시대색 진행바.
///
/// [duration] 동안 0→100%로 차오르며 끝으로 갈수록 느려진다(기대감).
/// 진행률은 시각 표현일 뿐 — 전환 트리거는 컨트롤러가 담당한다.
class EraProgressBar extends HookWidget {
  /// 채움 색 (시대 강조색)
  final Color fillColor;

  /// 0→100% 진행 시간
  final Duration duration;

  const EraProgressBar({super.key, required this.fillColor, required this.duration});

  @override
  Widget build(BuildContext context) {
    final bool reduce = MediaQuery.of(context).disableAnimations;
    final AnimationController progress = useAnimationController(duration: duration);
    useEffect(() {
      if (reduce) {
        progress.value = 1.0;
      } else {
        progress.forward();
      }
      return null;
    }, const <Object>[]);
    return SizedBox(
      width: 200,
      height: 6,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.surfaceSunken,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: AnimatedBuilder(
          animation: progress,
          builder: (BuildContext context, _) {
            return FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _eased(progress.value),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: fillColor,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 끝으로 갈수록 느려지는 ease-out (시안의 1 - (1 - t)^2.2)
  double _eased(double t) => 1 - math.pow(1 - t, 2.2).toDouble();
}
