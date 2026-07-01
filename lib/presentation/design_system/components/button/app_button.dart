import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_fonts.dart';
import 'package:picsong/presentation/design_system/foundation/app_motion.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';

/// 앱 공통 버튼
class AppButton extends HookWidget {
  final TextDecoration? textDecoration;
  final String text;
  final Color? textColor;
  final Color? disableTextColor;
  final Color? color;
  final Color? disableColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final VoidCallback onTapped;
  final int? maxLines;
  final double? borderRadius;
  final double? margin;
  final double? verticalMargin;
  final double? height;
  final double? width;
  final BoxBorder? border;
  final bool? disabled;
  final Widget? leading;

  const AppButton({
    super.key,
    required this.text,
    this.color,
    this.disableTextColor,
    this.disableColor,
    this.fontFamily,
    this.height,
    this.textAlign,
    this.overflow,
    this.maxLines,
    this.margin,
    this.borderRadius,
    required this.onTapped,
    this.width,
    this.textColor,
    this.fontWeight,
    this.disabled,
    this.fontSize,
    this.border,
    this.leading,
    this.verticalMargin,
    this.textDecoration,
  });

  @override
  Widget build(BuildContext context) {
    final scale = useState(1.0);

    void handleHighlightChanged(bool isHighlighted) {
      if (disabled == true) return;

      scale.value = isHighlighted ? AppMotion.pressScale : 1.0;

      if (isHighlighted) {
        HapticFeedback.lightImpact();
      }
    }

    return AnimatedScale(
      scale: scale.value,
      duration: AppMotion.durationFast,
      curve: AppMotion.standard,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? 50,
        margin: EdgeInsets.only(
          left: margin ?? AppSpacing.screenHorizontal,
          right: margin ?? AppSpacing.screenHorizontal,
          top: verticalMargin ?? 0,
          bottom: verticalMargin ?? 0,
        ),
        decoration: BoxDecoration(
          color: disabled == true
              ? disableColor ?? AppColors.neutral200
              : color ?? AppColors.primary,
          border: border,
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppRadius.md,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius ?? AppRadius.md)),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: disabled == true ? null : onTapped,
              onHighlightChanged: handleHighlightChanged,
              splashColor: Colors.white.withValues(alpha: 0.1),
              highlightColor: Colors.white.withValues(alpha: 0.05),
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (leading != null)
                      Row(
                        children: [
                          leading!,
                          const Gap(width: 6),
                        ],
                      ),
                    Text(
                      text,
                      textAlign: textAlign ?? TextAlign.center,
                      overflow: overflow,
                      maxLines: maxLines,
                      style: TextStyle(
                        decoration: textDecoration ?? TextDecoration.none,
                        fontFamily: AppFonts.pretendard,
                        fontWeight: fontWeight ?? FontWeight.w500,
                        fontSize: fontSize ?? 16,
                        letterSpacing: 0.02,
                        color: disabled == true
                            ? disableTextColor ?? AppColors.neutral400
                            : textColor ?? AppColors.onPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
