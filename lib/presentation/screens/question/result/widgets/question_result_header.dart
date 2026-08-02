import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_typography.dart';

/// 문제 결과 헤더 — 정답(체크)과 답안 공개(아쉬워요)로 분기한다.
class QuestionResultHeader extends StatelessWidget {
  /// 정답을 맞혔는지 여부
  final bool isCorrect;

  const QuestionResultHeader({super.key, required this.isCorrect});

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
        const Gap(height: AppSpacing.sm),
        AppText(
          text: '정답!',
          style: AppTypography.title1,
          color: AppColors.success,
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
        const Gap(height: AppSpacing.sm),
        AppText(
          text: '오답!',
          style: AppTypography.title1,
          color: AppColors.error,
          textAlign: TextAlign.center,
        ),
        const Gap(height: AppSpacing.sm),
        AppText(
          text: '정답은 이 노래였어요',
          style: AppTypography.body,
          color: AppColors.textMuted,
          textAlign: TextAlign.center,
        ),
      ];
}
