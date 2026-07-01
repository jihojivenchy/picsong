import 'package:flutter/cupertino.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';

class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.text,
    this.textColor = AppColors.textBody,
    this.borderColor = AppColors.transparent,
    this.borderWidth = 0,
    this.fontSize = 16,
    this.fontWeight = FontWeight.w500,
    this.backgroundColor = AppColors.neutral100,
    this.borderRadius = AppRadius.pill,
    this.padding = const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
  });

  final String text;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;
  final Color backgroundColor;
  final double borderRadius;
  final Color borderColor;
  final double borderWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: AppText(
        text: text,
        color: textColor,
        fontSize: fontSize,
        fontWeight: fontWeight,
      ),
    );
  }
}
