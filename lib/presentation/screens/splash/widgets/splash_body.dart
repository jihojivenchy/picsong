import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:picsong/presentation/design_system/components/brand/picsong_logo.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_motion.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_typography.dart';

/// 스플래시 브랜드 등장 연출.
///
/// 글로우 → 워드마크 settle(ds-reveal) → "i" 코랄 점 bloom → 태그라인 →
/// 하단 점 펄스 순으로 등장하고, 약 2.4초 머문 뒤 페이드아웃하며 [onFinished]를 호출한다.
class SplashBody extends HookWidget {
  /// 등장 타임라인 (ms) — 시안 키프레임 딜레이를 1:1 포팅
  static const int _enterTotalMs = 2400;
  static const int _wordStartMs = 180;
  static const int _dotStartMs = 720;
  static const int _tagStartMs = 1000;
  static const int _reducedHoldMs = 700;

  /// 하단 점 펄스 위상차 (160·320ms / 1200ms 주기)
  static const List<double> _dotPhases = <double>[0.0, 0.1333, 0.2667];

  /// 등장·머묾·퇴장 연출이 끝났을 때 호출 (다음 화면 전환 트리거)
  final VoidCallback onFinished;

  const SplashBody({super.key, required this.onFinished});

  @override
  Widget build(BuildContext context) {
    final bool reduce = MediaQuery.of(context).disableAnimations;
    final AnimationController enter = useAnimationController(
      duration: Duration(milliseconds: reduce ? _reducedHoldMs : _enterTotalMs),
    );
    final AnimationController leave = useAnimationController(duration: AppMotion.durationSlow);
    final AnimationController pulse = useAnimationController(duration: const Duration(milliseconds: 1200));

    useEffect(() {
      void onEnter(AnimationStatus status) {
        if (status == AnimationStatus.completed) leave.forward();
      }
      void onLeave(AnimationStatus status) {
        if (status == AnimationStatus.completed) onFinished();
      }
      enter.addStatusListener(onEnter);
      leave.addStatusListener(onLeave);
      if (!reduce) pulse.repeat();
      enter.forward();
      return () {
        enter.removeStatusListener(onEnter);
        leave.removeStatusListener(onLeave);
      };
    }, const <Object>[]);

    final double ev = useAnimation(enter);
    final double lv = useAnimation(leave);
    final double pv = useAnimation(pulse);
    final double leaveOpacity = 1.0 - AppMotion.accelerate.transform(lv);

    return Opacity(
      opacity: leaveOpacity,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          _buildGlow(reduce ? 1.0 : ev),
          _buildCenter(reduce, ev),
          _buildDots(reduce, pv),
        ],
      ),
    );
  }

  ///
  /// 따뜻한 코랄 글로우 — 한 번 천천히 피어올라 자리잡는다.
  ///
  Widget _buildGlow(double p) {
    final double opacity = p < 0.45 ? _lerp(0.0, 0.95, p / 0.45) : _lerp(0.95, 0.55, (p - 0.45) / 0.55);
    final double scale = _lerp(0.7, 1.0, AppMotion.standard.transform(p));
    return Center(
      child: Opacity(
        opacity: opacity.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: scale,
          child: Container(
            width: 460,
            height: 460,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                radius: 0.5,
                colors: <Color>[AppColors.primarySoft, AppColors.primarySoft.withValues(alpha: 0)],
                stops: const <double>[0.0, 0.68],
              ),
            ),
          ),
        ),
      ),
    );
  }

  ///
  /// 워드마크(ds-reveal settle + 점 bloom) + 태그라인.
  ///
  Widget _buildCenter(bool reduce, double ev) {
    final double wp = AppMotion.emphasized.transform(reduce ? 1.0 : _seg(ev, _wordStartMs, AppMotion.durationSlow.inMilliseconds));
    final double dotScale = _dotBloom(reduce ? 1.0 : _seg(ev, _dotStartMs, AppMotion.durationBase.inMilliseconds));
    final double tp = AppMotion.decelerate.transform(reduce ? 1.0 : _seg(ev, _tagStartMs, AppMotion.durationBase.inMilliseconds));
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Opacity(
            opacity: wp.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, _lerp(6, 0, wp)),
              child: Transform.scale(
                scale: _lerp(0.98, 1.0, wp),
                child: PicSongLogo(fontSize: 48, dotScale: dotScale),
              ),
            ),
          ),
          const Gap(height: AppSpacing.lg),
          Opacity(
            opacity: tp.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, _lerp(8, 0, tp)),
              child: AppText(
                text: '그림을 보고 노래를 맞혀요',
                textAlign: TextAlign.center,
                style: AppTypography.bodyLg,
                color: AppColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  ///
  /// 하단 차분한 로딩 점 — 진입부터 전환까지 줄곧 펄스하며 기대감을 만든다.
  ///
  Widget _buildDots(bool reduce, double pv) {
    return Positioned(
      left: 0,
      right: 0,
      bottom: 72,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: AppSpacing.sm,
        children: List<Widget>.generate(
          _dotPhases.length,
          (int i) => _buildPulseDot(reduce ? null : (pv + _dotPhases[i]) % 1.0),
        ),
      ),
    );
  }

  ///
  /// 펄스 점 1개. [phase]가 null이면 reduced-motion 정적(opacity 0.35).
  ///
  Widget _buildPulseDot(double? phase) {
    final double wave = phase == null ? 0.0 : 0.5 - 0.5 * math.cos(2 * math.pi * phase);
    final double opacity = phase == null ? 0.35 : _lerp(0.3, 1.0, wave);
    final double scale = phase == null ? 1.0 : _lerp(0.8, 1.0, wave);
    return Opacity(
      opacity: opacity,
      child: Transform.scale(
        scale: scale,
        child: Container(
          width: 7,
          height: 7,
          decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        ),
      ),
    );
  }

  ///
  /// 등장 컨트롤러 값[v]을 [startMs]~[startMs+durMs] 구간 진행도(0~1)로 변환.
  ///
  static double _seg(double v, int startMs, int durMs) {
    return ((v * _enterTotalMs - startMs) / durMs).clamp(0.0, 1.0);
  }

  ///
  /// 점 bloom — scale 0 → 1.3(62%) → 1.0, 각 구간 emphasized.
  ///
  static double _dotBloom(double t) {
    if (t <= 0) return 0.0;
    if (t >= 1) return 1.0;
    if (t < 0.62) return _lerp(0.0, 1.3, AppMotion.emphasized.transform(t / 0.62));
    return _lerp(1.3, 1.0, AppMotion.emphasized.transform((t - 0.62) / 0.38));
  }

  static double _lerp(double a, double b, double t) => a + (b - a) * t;
}
