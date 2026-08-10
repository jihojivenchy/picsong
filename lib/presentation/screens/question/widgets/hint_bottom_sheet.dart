import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:picsong/domain/entities/song/hint.dart';
import 'package:picsong/presentation/design_system/components/button/app_button.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_typography.dart';

/// 힌트 바텀시트 — 곡별 힌트 / 발매연도 / 장르를 1회 제공.
class HintBottomSheet extends StatelessWidget {
  /// 그랩 핸들 너비
  static const double _grabWidth = 40;

  /// 그랩 핸들 높이
  static const double _grabHeight = 4;

  /// 헤더 아이콘 원 지름
  static const double _sparkSize = 36;

  /// 표시할 힌트 항목
  final List<Hint> hints;

  const HintBottomSheet._({required this.hints});

  ///
  /// 힌트 시트 표시
  ///
  static Future<void> show(
    BuildContext context, {
    required List<Hint> hints,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => HintBottomSheet._(hints: hints),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.screenHorizontal,
        AppSpacing.md,
        AppSpacing.screenHorizontal,
        AppSpacing.xxl,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildGrabHandle(),
            const Gap(height: AppSpacing.lg),
            _buildHeader(),
            const Gap(height: AppSpacing.xs),
            AppText(
              text: '힌트는 한 번만 볼 수 있어요.',
              style: AppTypography.caption,
              color: AppColors.textSubtle,
            ),
            const Gap(height: AppSpacing.lg),
            ..._buildHintRows(),
            const Gap(height: AppSpacing.xl),
            AppButton(text: '확인', margin: 0, onTapped: () => context.pop()),
          ],
        ),
      ),
    );
  }

  /// 상단 그랩 핸들
  Widget _buildGrabHandle() {
    return Center(
      child: Container(
        width: _grabWidth,
        height: _grabHeight,
        decoration: BoxDecoration(
          color: AppColors.borderStrong,
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
      ),
    );
  }

  /// 헤더 — 전구 아이콘 + 제목
  Widget _buildHeader() {
    return Row(
      children: <Widget>[
        Container(
          width: _sparkSize,
          height: _sparkSize,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primarySoft,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.lightbulb_outline,
            size: 20,
            color: AppColors.primary,
          ),
        ),
        const Gap(width: AppSpacing.sm),
        AppText(
          text: '힌트',
          style: AppTypography.title3,
          color: AppColors.textStrong,
        ),
      ],
    );
  }

  /// 힌트 행 목록 (행 사이 구분선)
  List<Widget> _buildHintRows() {
    return <Widget>[
      for (int i = 0; i < hints.length; i++) ...<Widget>[
        if (i > 0)
          const Divider(height: 1, thickness: 1, color: AppColors.borderSubtle),
        _buildHintRow(hints[i]),
      ],
    ];
  }

  /// 힌트 행 1개 (라벨 ↔ 값)
  Widget _buildHintRow(Hint hint) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          AppText(
            text: hint.label,
            style: AppTypography.body,
            color: AppColors.textMuted,
          ),
          AppText(
            text: hint.value,
            style: AppTypography.title3,
            color: AppColors.textStrong,
          ),
        ],
      ),
    );
  }
}
