import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';

class AppCategoryBar<T extends Enum> extends StatelessWidget {
  const AppCategoryBar({
    super.key,
    required this.currentCategory,
    required this.categoryList,
    required this.labelBuilder,
    this.backgroundColor = AppColors.transparent,
    required this.onCategoryChanged,
  });

  final T currentCategory;
  final List<T> categoryList;
  final String Function(T) labelBuilder;
  final Color? backgroundColor;
  final Function(T) onCategoryChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: SizedBox(
        width: double.infinity,
        height: 43,
        child: ListView.separated(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          itemCount: categoryList.length,
          scrollDirection: Axis.horizontal,
          itemBuilder: (context, index) {
            final category = categoryList[index];
            return _buildTabButton(context, category);
          },
          separatorBuilder: (context, index) {
            return const Gap(width: 11);
          },
        ),
      ),
    );
  }

  Widget _buildTabButton(
    BuildContext context,
    T category,
  ) {
    final isSelected = category == currentCategory;

    return GestureDetector(
      onTap: () => onCategoryChanged(category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.color8C7565,
            width: 1,
          ),
        ),
        child: Center(
          child: AppText(
            text: labelBuilder(category),
            fontSize: 16,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
            color: isSelected ? AppColors.white : AppColors.color8C7565,
          ),
        ),
      ),
    );
  }
}
