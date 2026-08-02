import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/button/app_button.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_typography.dart';
import 'package:picsong/presentation/screens/onboarding/widgets/onboarding_step_layout.dart';

/// 온보딩 Step 1 — 게임 소개
class OnboardingIntroStep extends StatelessWidget {
  /// 주 액션 버튼 높이 (디자인시스템 Button lg)
  static const double _actionButtonHeight = 60;

  /// 다음 스텝으로 이동
  final VoidCallback onNext;

  const OnboardingIntroStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return OnboardingStepLayout(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Gap(height: AppSpacing.xxxl),
          const AppText(
            text: '그림 한 장으로\n노래를 맞혀보세요',
            style: AppTypography.title1,
            color: AppColors.textStrong,
            overflow: TextOverflow.visible,
          ),
          const Gap(height: AppSpacing.md),
          const AppText(
            text: '가사 한 줄이 그림이 돼요.\n그림을 보고 어떤 노래인지 맞히는 게임이에요.',
            style: AppTypography.bodyLg,
            color: AppColors.textMuted,
            overflow: TextOverflow.visible,
          ),
        ],
      ),
      foot: AppButton(
        text: '다음',
        height: _actionButtonHeight,
        fontSize: AppTypography.title3.fontSize,
        fontWeight: FontWeight.w600,
        margin: 0,
        onTapped: onNext,
      ),
    );
  }
}
