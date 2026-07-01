import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';

class AppRadioButton<T> extends StatelessWidget {
  final T value;
  final T groupValue;
  final ValueChanged<T> onChanged;

  double? borderWidth;

  Color? selectedColor;
  Color? unSelectedColor;
  Color? circleColor;

  AppRadioButton(
      {super.key,
      required this.value,
      required this.groupValue,
      required this.onChanged,
      this.selectedColor,
      this.unSelectedColor,
      this.borderWidth});

  @override
  Widget build(BuildContext context) {
    final isSelected = value == groupValue;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onChanged(value),
      child: Row(
        children: [
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            width: 20,
            height: 20,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? selectedColor : unSelectedColor,
                border: Border.all(
                  color: isSelected
                      ? selectedColor ?? AppColors.appColor
                      : AppColors.stroke,
                  width: isSelected ? 6 : 1,
                )),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? circleColor : unSelectedColor,
                      ),
                    ),
                  )
                : null,
          ),
          const Gap(width: AppSpacing.sm),
          AppText(text: value.toString()),
        ],
      ),
    );
  }
}
