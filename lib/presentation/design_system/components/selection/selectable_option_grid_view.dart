import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/components/grid/dynamic_height_grid_view.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';

class SelectableOptionGridView<T> extends StatelessWidget {
  const SelectableOptionGridView({
    super.key,
    required this.selectedOption,
    required this.optionList,
    required this.labelBuilder,
    required this.onOptionTapped,
  });

  final T selectedOption;
  final List<T> optionList;
  final String Function(T) labelBuilder;
  final Function(T) onOptionTapped;

  @override
  Widget build(BuildContext context) {
    return DynamicHeightGridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: optionList.length,
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      rowCrossAxisAlignment: CrossAxisAlignment.start,
      builder: (context, index) {
        final option = optionList[index];
        final isSelected = option == selectedOption;

        return InkWell(
          onTap: () => onOptionTapped(option),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.gray200,
                width: isSelected ? 2 : 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Center(
              child: AppText(
                text: labelBuilder(option),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isSelected ? AppColors.primary : AppColors.gray500,
              ),
            ),
          ),
        );
      },
    );
  }
}
