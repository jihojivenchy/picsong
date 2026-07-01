import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/brand/picsong_logo.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_typography.dart';

/// 홈 상단 헤더
class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Gap(height: AppSpacing.xl),
        const PicSongLogo(fontSize: 32),
        const Gap(height: AppSpacing.xl),
        AppText(
          text: '어떤 시절의 노래로 놀아볼까요?',
          style: AppTypography.body,
          color: AppColors.textMuted,
        ),
        const Gap(height: AppSpacing.xl),
      ],
    );
  }
}
