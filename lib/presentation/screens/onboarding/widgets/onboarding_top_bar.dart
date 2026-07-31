import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_motion.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_typography.dart';

/// 온보딩 상단 바 — 스텝 진행바 + 건너뛰기
class OnboardingTopBar extends StatelessWidget {
  /// 상단 바 높이
  static const double _barHeight = 56;

  /// 진행바 두께
  static const double _trackHeight = 4;

  /// 건너뛰기 터치 여백
  static const double _skipPadding = AppSpacing.sm;

  /// 진행 비율 (0.0 ~ 1.0)
  final double progress;

  /// 건너뛰기 콜백 — null이면 건너뛰기를 노출하지 않는다
  final VoidCallback? onSkip;

  const OnboardingTopBar({
    super.key,
    required this.progress,
    this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasSkip = onSkip != null;

    return SizedBox(
      height: _barHeight,
      child: Padding(
        // 건너뛰기의 터치 여백만큼 오른쪽 여백을 당겨 글자를 화면 여백선에 맞춘다
        padding: EdgeInsets.only(
          left: AppSpacing.screenHorizontal,
          right: hasSkip
              ? AppSpacing.screenHorizontal - _skipPadding
              : AppSpacing.screenHorizontal,
        ),
        child: Row(
          children: <Widget>[
            Expanded(child: _buildTrack()),
            if (hasSkip) ...<Widget>[
              const Gap(width: AppSpacing.lg),
              _buildSkip(),
            ],
          ],
        ),
      ),
    );
  }

  /// 진행바 트랙 + 채움
  Widget _buildTrack() {
    return Container(
      height: _trackHeight,
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0, end: progress),
          duration: AppMotion.durationSlow,
          curve: AppMotion.emphasized,
          builder: (BuildContext context, double value, Widget? child) {
            return Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: value,
                heightFactor: 1,
                child: const DecoratedBox(
                  decoration: BoxDecoration(color: AppColors.primary),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// 건너뛰기 버튼
  Widget _buildSkip() {
    return InkWell(
      onTap: onSkip,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: const Padding(
        padding: EdgeInsets.all(_skipPadding),
        child: AppText(
          text: '건너뛰기',
          style: AppTypography.label,
          color: AppColors.textMuted,
        ),
      ),
    );
  }
}
