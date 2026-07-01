import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';

/// 앱 전역에서 사용하는 일반적인 Toast Widget
class AppToastWidget extends StatelessWidget {
  const AppToastWidget({super.key, required this.text, this.isTop = false});

  final String text;

  /// 상단 토스트 여부
  final bool isTop;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.maxFinite,
      margin: EdgeInsets.only(
        top: isTop ? 20 : 0,
        bottom: isTop ? 0 : 20,
        left: AppSpacing.lg,
        right: AppSpacing.lg,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.gray800,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: AppText(
        text: text,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.white,
        overflow: TextOverflow.visible,
      ),
    );
  }
}
