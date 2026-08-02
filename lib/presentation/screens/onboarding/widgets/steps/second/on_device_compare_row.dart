import 'dart:ui' show PathMetric;

import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';
import 'package:picsong/presentation/design_system/foundation/app_shadows.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_typography.dart';

/// 온보딩 Step 2 비교 행 — 미리 생성(탈락) vs 온디바이스 생성(채택)
class OnDeviceCompareRow extends StatelessWidget {
  /// 아이콘 타일 크기
  static const double _tileSize = 44;

  /// 아이콘 크기
  static const double _iconSize = 22;

  /// 판정 아이콘 크기
  static const double _verdictIconSize = 18;

  /// 채택 행 여부 — 색·테두리·판정 아이콘이 함께 달라진다
  final bool isActive;

  /// 타일 아이콘
  final IconData icon;

  /// 행 제목
  final String title;

  /// 행 설명
  final String caption;

  const OnDeviceCompareRow({
    super.key,
    required this.isActive,
    required this.icon,
    required this.title,
    required this.caption,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: _buildContent(),
    );
    if (isActive) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.borderSubtle),
          boxShadow: AppShadows.elevation1,
        ),
        child: content,
      );
    }
    return CustomPaint(
      painter: const _DashedBorderPainter(
        color: AppColors.borderDefault,
        radius: AppRadius.lg,
      ),
      child: content,
    );
  }

  /// 타일 + 텍스트 + 판정 아이콘
  Widget _buildContent() {
    return Row(
      children: <Widget>[
        Container(
          width: _tileSize,
          height: _tileSize,
          decoration: BoxDecoration(
            color: isActive ? AppColors.primarySoft : AppColors.surfaceSunken,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(
            icon,
            size: _iconSize,
            color: isActive ? AppColors.primary : AppColors.textSubtle,
          ),
        ),
        const Gap(width: AppSpacing.lg),
        Expanded(child: _buildTexts()),
        const Gap(width: AppSpacing.lg),
        Icon(
          isActive ? Icons.check_rounded : Icons.close_rounded,
          size: _verdictIconSize,
          color: isActive ? AppColors.primary : AppColors.textSubtle,
        ),
      ],
    );
  }

  /// 제목 + 설명
  Widget _buildTexts() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        AppText(
          text: title,
          style: AppTypography.label,
          color: isActive ? AppColors.textStrong : AppColors.textMuted,
        ),
        const Gap(height: 2),
        AppText(
          text: caption,
          style: AppTypography.caption,
          color: isActive ? AppColors.textMuted : AppColors.textSubtle,
        ),
      ],
    );
  }
}

/// 탈락 행의 점선 테두리
class _DashedBorderPainter extends CustomPainter {
  /// 점선 길이
  static const double _dashLength = 4;

  /// 점선 간격
  static const double _gapLength = 4;

  /// 테두리 색
  final Color color;

  /// 모서리 라디우스
  final double radius;

  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final Path border = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    for (final PathMetric metric in border.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + _dashLength),
          paint,
        );
        distance += _dashLength + _gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) {
    return color != oldDelegate.color || radius != oldDelegate.radius;
  }
}
