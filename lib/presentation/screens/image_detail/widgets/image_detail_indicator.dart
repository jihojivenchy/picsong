import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_typography.dart';

/// 지금 몇 번째 그림을 보고 있는지 알려주는 배지
class ImageDetailIndicator extends StatelessWidget {
  /// 현재 보고 있는 그림 위치(0부터)
  final int currentIndex;

  /// 전체 그림 수
  final int totalCount;

  const ImageDetailIndicator({
    super.key,
    required this.currentIndex,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.overlayBlack66,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: AppText(
        text: '${currentIndex + 1} / $totalCount',
        style: AppTypography.label,
        color: AppColors.white,
      ),
    );
  }
}
