import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_motion.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';
import 'package:picsong/presentation/design_system/foundation/app_shadows.dart';

/// 그림 생성 연출 액자.
///
/// 시대색·코랄 물감 blob이 캔버스 안에서 번지고(bloom), 렌더 시머가 가로지르며,
/// 중앙 스파크 배지가 숨쉬듯 펄스한다. reduced-motion 시 정지 상태로 표시한다.
class GenerationCanvas extends HookWidget {
  /// 액자 한 변 길이
  static const double _size = 280;

  /// blob 블러 강도
  static const double _blobBlur = 24;

  /// 캔버스 안에서 번지는 시대 강조색
  final Color accentColor;

  const GenerationCanvas({super.key, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    final bool reduce = MediaQuery.of(context).disableAnimations;
    final AnimationController bloom = useAnimationController(
      duration: const Duration(milliseconds: 4600),
    );
    final AnimationController shimmer = useAnimationController(duration: AppMotion.shimmer);
    useEffect(() {
      if (!reduce) {
        bloom.repeat();
        shimmer.repeat();
      }
      return null;
    }, <Object>[reduce]);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        boxShadow: AppShadows.elevationImage,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        child: SizedBox(
          width: _size,
          height: _size,
          child: Stack(
            children: <Widget>[
              _buildBlobs(bloom, reduce),
              _buildShimmer(shimmer, reduce),
            ],
          ),
        ),
      ),
    );
  }

  ///
  /// 시대색·코랄 물감 자국 3개가 위상차를 두고 번진다.
  ///
  Widget _buildBlobs(AnimationController bloom, bool reduce) {
    final List<_Blob> blobs = <_Blob>[
      _Blob(color: accentColor, left: 0.08, top: 0.12, size: 0.62, dx: 26, dy: 20, delay: 0.0),
      _Blob(color: AppColors.primary, left: 0.42, top: 0.38, size: 0.56, dx: -22, dy: -16, delay: 0.196),
      _Blob(color: accentColor, left: 0.30, top: 0.46, size: 0.50, dx: 12, dy: -24, delay: 0.391),
    ];
    return AnimatedBuilder(
      animation: bloom,
      builder: (BuildContext context, _) {
        return Stack(
          children: blobs
              .map((_Blob blob) => _buildBlob(blob, bloom.value, reduce))
              .toList(),
        );
      },
    );
  }

  ///
  /// 단일 blob — bloom 진행도[t]에 따라 위치·스케일·불투명도가 함께 부푼다.
  ///
  Widget _buildBlob(_Blob blob, double t, bool reduce) {
    final double phase = (t + blob.delay) % 1.0;
    final double wave = reduce ? 0.5 : 0.5 - 0.5 * math.cos(2 * math.pi * phase);
    final double dim = _size * blob.size;
    return Positioned(
      left: _size * blob.left + blob.dx * wave,
      top: _size * blob.top + blob.dy * wave,
      child: Opacity(
        opacity: 0.28 + 0.32 * wave,
        child: ImageFiltered(
          imageFilter: ui.ImageFilter.blur(sigmaX: _blobBlur, sigmaY: _blobBlur),
          child: Transform.scale(
            scale: 0.82 + 0.38 * wave,
            child: Container(
              width: dim,
              height: dim,
              decoration: BoxDecoration(color: blob.color, shape: BoxShape.circle),
            ),
          ),
        ),
      ),
    );
  }

  ///
  /// 렌더 패스처럼 캔버스를 가로지르는 빛 스윕.
  ///
  Widget _buildShimmer(AnimationController shimmer, bool reduce) {
    if (reduce) return const SizedBox.shrink();
    return AnimatedBuilder(
      animation: shimmer,
      builder: (BuildContext context, _) {
        return Center(
          child: Transform.translate(
            offset: Offset((shimmer.value * 2 - 1) * _size, 0),
            child: Transform.rotate(
              angle: -0.18,
              child: Container(
                width: _size * 0.5,
                height: _size * 1.6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: <Color>[
                      Colors.white.withValues(alpha: 0),
                      Colors.white.withValues(alpha: 0.5),
                      Colors.white.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// blob 한 개의 정적 배치값 (비율·이동·위상).
class _Blob {
  /// 물감 색
  final Color color;

  /// 캔버스 대비 좌측 비율
  final double left;

  /// 캔버스 대비 상단 비율
  final double top;

  /// 캔버스 대비 지름 비율
  final double size;

  /// 가로 이동량(px)
  final double dx;

  /// 세로 이동량(px)
  final double dy;

  /// bloom 위상 오프셋(0~1)
  final double delay;

  const _Blob({
    required this.color,
    required this.left,
    required this.top,
    required this.size,
    required this.dx,
    required this.dy,
    required this.delay,
  });
}
