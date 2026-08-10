import 'package:flutter/material.dart';
import 'package:picsong/domain/entities/era/era.dart';
import 'package:picsong/presentation/common/extensions/era_extension.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';
import 'package:picsong/presentation/design_system/foundation/app_shadows.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_typography.dart';

/// 시대 선택 카드
class EraItem extends StatelessWidget {
  final Era era;
  final VoidCallback onTap;

  const EraItem({
    super.key,
    required this.era,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: era.softColor,
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppShadows.elevation1,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Stack(
            children: <Widget>[
              Positioned(
                right: -8,
                top: 0,
                bottom: 0,
                child: Center(child: _buildWatermark()),
              ),
              Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 80),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: AppText(
                      text: era.label,
                      style: AppTypography.title2,
                      color: AppColors.textStrong,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 우측 반투명 연도 워터마크 — 자릿수가 늘면 폰트를 줄여 라벨과 겹치지 않게 한다
  Widget _buildWatermark() {
    final double fontSize = era.watermark.length > 2 ? 64 : 108;

    return AppText(
      text: era.watermark,
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      letterSpacing: fontSize * -0.05,
      height: 1,
      color: era.color.withValues(alpha: 0.2),
    );
  }
}
