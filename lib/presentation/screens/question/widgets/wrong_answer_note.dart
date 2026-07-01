import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_typography.dart';

/// 오답 안내 — 그림을 가리지 않는 비차단형 soft rose 인라인 배너(알람 아님).
class WrongAnswerNote extends StatelessWidget {
  const WrongAnswerNote({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.errorSoft,
        border: Border.all(color: AppColors.borderSubtle),
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Row(
        children: <Widget>[
          AppText(
            text: '아쉬워요',
            style: AppTypography.body,
            color: AppColors.error,
            fontWeight: FontWeight.w600,
          ),
          Flexible(
            child: AppText(
              text: ' · 다시 한 번 떠올려볼까요?',
              style: AppTypography.body,
              color: AppColors.textBody,
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }
}
