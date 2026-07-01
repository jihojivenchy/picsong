import 'dart:math';

import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';

/// 항목 추가 버튼 (Dashed border + 플러스 아이콘)
class DashedAddButton extends StatelessWidget {
  const DashedAddButton({
    super.key,
    required this.onTapped,
  });

  /// 탭 콜백
  final VoidCallback onTapped;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTapped,
      child: CustomPaint(
        painter: _DashedBorderPainter(
          color: AppColors.figmaGray200,
          strokeWidth: 1.5,
          dashWidth: 6,
          dashGap: 4,
          borderRadius: 12,
        ),
        child: Container(
          height: 82,
          alignment: Alignment.center,
          child: Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.gray100,
            ),
            child: const Icon(
              Icons.add,
              size: 20,
              color: AppColors.gray400,
            ),
          ),
        ),
      ),
    );
  }
}

/// Dashed border 커스텀 페인터
class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashWidth,
    required this.dashGap,
    required this.borderRadius,
  });

  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashGap;
  final double borderRadius;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final RRect rRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(borderRadius),
    );

    final Path path = Path()..addRRect(rRect);
    final Path dashedPath = _createDashedPath(path);
    canvas.drawPath(dashedPath, paint);
  }

  /// 실선 Path를 dashed Path로 변환
  Path _createDashedPath(Path source) {
    final Path dashedPath = Path();
    for (final metric in source.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final double end = min(distance + dashWidth, metric.length);
        dashedPath.addPath(
          metric.extractPath(distance, end),
          Offset.zero,
        );
        distance += dashWidth + dashGap;
      }
    }
    return dashedPath;
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.dashWidth != dashWidth ||
        oldDelegate.dashGap != dashGap ||
        oldDelegate.borderRadius != borderRadius;
  }
}
