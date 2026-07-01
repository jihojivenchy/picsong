import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_typography.dart';

/// 정답 공개 결과 헤더 — 정답(체크)과 답안 공개(아쉬워요)로 분기한다.
class RevealHeader extends StatelessWidget {
  /// 정답 아이콘 원의 지름
  static const double _iconSize = 56;

  /// 정답을 맞혔는지 여부
  final bool isCorrect;

  const RevealHeader({super.key, required this.isCorrect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: isCorrect ? _buildCorrect() : _buildRevealed(),
      ),
    );
  }

  /// 정답: 성공 아이콘 + 축하 문구 + 보조 문구
  List<Widget> _buildCorrect() => <Widget>[
        Container(
          width: _iconSize,
          height: _iconSize,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.successSoft,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_rounded,
            color: AppColors.success,
            size: 28,
          ),
        ),
        const Gap(height: AppSpacing.sm),
        AppText(
          text: '정답이에요! 🎉',
          style: AppTypography.title2,
          color: AppColors.textStrong,
          textAlign: TextAlign.center,
        ),
        const Gap(height: AppSpacing.sm),
        AppText(
          text: '이 노래가 떠오른 그림이었어요',
          style: AppTypography.body,
          color: AppColors.textMuted,
          textAlign: TextAlign.center,
        ),
      ];

  /// 답안 공개: '아쉬워요' 칩 + 정답 안내 문구
  List<Widget> _buildRevealed() => <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: AppColors.errorSoft,
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: AppText(
            text: '아쉬워요',
            style: AppTypography.label,
            color: AppColors.error,
          ),
        ),
        const Gap(height: AppSpacing.sm),
        AppText(
          text: '정답은 이 노래였어요',
          style: AppTypography.title2,
          color: AppColors.textStrong,
          textAlign: TextAlign.center,
        ),
      ];
}
