import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';

/// 라운드 준비 진행바 (시대색).
///
/// 최악의 경우(콜드 ANE 컴파일 ~60초)에 맞춰 차오르며 끝으로 갈수록 느려진다.
/// **실제 진행률이 아니라 경과 시간 기반 연출이다** — 전환 트리거는 컨트롤러가 담당한다.
class PreparationProgressBar extends HookWidget {
  /// 0→최대치 진행 시간 — 콜드 ANE 컴파일 실측(~60초)에 맞췄다
  static const Duration _fillDuration = Duration(seconds: 60);

  /// 최대 채움 비율 — 준비가 끝나기 전에 100%에 닿아 "다 됐다"고 거짓말하지 않는다
  static const double _maxFill = 0.9;

  /// 채움 색 (시대 강조색)
  final Color fillColor;

  const PreparationProgressBar({super.key, required this.fillColor});

  @override
  Widget build(BuildContext context) {
    final bool reduce = MediaQuery.of(context).disableAnimations;
    final AnimationController progress = useAnimationController(
      duration: _fillDuration,
    );
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
              widthFactor: _eased(progress.value) * _maxFill,
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
