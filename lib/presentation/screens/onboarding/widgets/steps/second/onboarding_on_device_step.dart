import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/button/app_button.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_typography.dart';
import 'package:picsong/presentation/screens/onboarding/widgets/onboarding_step_layout.dart';
import 'package:picsong/presentation/screens/onboarding/widgets/steps/second/on_device_compare_row.dart';

/// 온보딩 Step 2 — 온디바이스 AI 설명 (다음 스텝 1GB 다운로드의 명분)
class OnboardingOnDeviceStep extends StatelessWidget {
  /// 주 액션 버튼 높이 (디자인시스템 Button lg)
  static const double _actionButtonHeight = 60;

  /// 오프라인 배지 아이콘 크기
  static const double _badgeIconSize = 18;

  /// 다음 스텝으로 이동
  final VoidCallback onNext;

  const OnboardingOnDeviceStep({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return OnboardingStepLayout(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Gap(height: AppSpacing.lg),
          const AppText(
            text: '그림은 핸드폰 안에서\n바로 만들어져요',
            style: AppTypography.title1,
            color: AppColors.textStrong,
            overflow: TextOverflow.visible,
          ),
          const Gap(height: AppSpacing.md),
          const AppText(
            text: '미리 그려둔 그림을 보여드리는 게 아니에요. 문제를 열 때마다 그 자리에서 새롭게 그려요.',
            style: AppTypography.bodyLg,
            color: AppColors.textMuted,
            overflow: TextOverflow.visible,
          ),
          const Gap(height: AppSpacing.xxl),
          const OnDeviceCompareRow(
            isActive: false,
            icon: Icons.cloud_off_rounded,
            title: '미리 만들어둔 그림',
            caption: '정해진 그림이 반복돼요',
          ),
          const Gap(height: AppSpacing.md),
          const OnDeviceCompareRow(
            isActive: true,
            icon: Icons.smartphone_rounded,
            title: '폰이 그 자리에서 그린 그림',
            caption: '문제마다 새 그림이 나와요',
          ),
          const Gap(height: AppSpacing.xl),
          Center(child: _buildOfflineBadge()),
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

  /// 오프라인 플레이 배지
  Widget _buildOfflineBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            Icons.wifi_off_rounded,
            size: _badgeIconSize,
            color: AppColors.primary,
          ),
          Gap(width: AppSpacing.sm),
          AppText(
            text: '인터넷 없이도 플레이할 수 있어요',
            style: AppTypography.label,
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}
