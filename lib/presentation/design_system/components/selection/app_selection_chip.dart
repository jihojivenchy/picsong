import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:flutter/widgets.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';

/// 선택 칩 위젯
class AppSelectionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTapped;

  const AppSelectionChip({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTapped,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapped,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.appPink : AppColors.background,
          borderRadius: BorderRadius.circular(AppRadius.xs),
        ),
        child: AppText(
          text: label,
          fontSize: 14,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          color: AppColors.basicText,
        ),
      ),
    );
  }
}
