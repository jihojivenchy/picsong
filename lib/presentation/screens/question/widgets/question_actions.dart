import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_typography.dart';

/// 문제 보조 액션 — 힌트 보기 / 답안 공개.
class QuestionActions extends StatelessWidget {
  /// 힌트 사용 여부 (사용 시 힌트 칩 비활성)
  final bool hintUsed;

  /// 힌트 보기 탭
  final VoidCallback onHintTapped;

  /// 답안 공개 탭
  final VoidCallback onRevealTapped;

  const QuestionActions({
    super.key,
    required this.hintUsed,
    required this.onHintTapped,
    required this.onRevealTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: <Widget>[
        _buildHintChip(),
        _buildAnswerChip(),
      ],
    );
  }

  /// 힌트 칩 — 사용 전 코랄 강조, 사용 후 비활성 톤
  Widget _buildHintChip() {
    final Color tint = hintUsed ? AppColors.textSubtle : AppColors.primary;
    return _buildChip(
      onTap: hintUsed ? null : onHintTapped,
      background: hintUsed ? AppColors.surfaceSunken : AppColors.primarySoft,
      icon: Icons.lightbulb_outline,
      iconColor: tint,
      label: hintUsed ? '힌트 사용함' : '힌트 보기',
      labelColor: tint,
    );
  }

  /// 답안 공개 칩
  Widget _buildAnswerChip() {
    return _buildChip(
      onTap: onRevealTapped,
      background: AppColors.surfaceCard,
      border: Border.all(color: AppColors.borderSubtle),
      icon: Icons.visibility_outlined,
      iconColor: AppColors.textMuted,
      label: '답안 공개',
      labelColor: AppColors.textBody,
    );
  }

  /// 공통 칩 (pill)
  Widget _buildChip({
    required VoidCallback? onTap,
    required Color background,
    required IconData icon,
    required Color iconColor,
    required String label,
    required Color labelColor,
    Border? border,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: background,
          border: border,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, size: 18, color: iconColor),
            const Gap(width: AppSpacing.xs),
            AppText(text: label, style: AppTypography.label, color: labelColor),
          ],
        ),
      ),
    );
  }
}
