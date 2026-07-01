import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:picsong/presentation/design_system/foundation/app_fonts.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';

class AppTextField extends StatelessWidget {
  final String? initialValue;
  final bool? isCollapsed;
  final TextEditingController? textController;
  final TextInputAction? textInputAction;
  final TextInputType? keyboardType;
  final AutovalidateMode? autoValidateMode;
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Widget? suffix;
  final Color? textColor;
  final FontWeight? fontWeight;
  final bool? obscureText;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final TextDecoration? textDecoration;
  final TextDecorationStyle? textDecorationStyle;
  final Color? textDecorationColor;
  final String? font;
  final bool? readOnly;
  final int? maxLength;
  final int? minLines;
  final int? maxLines;
  final TextAlign? textAlign;
  final double? fontSize;
  final TextStyle? textStyle;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;
  final Color? textBorderColor;
  final Color? textColorHint;
  final Color? fillColor;
  final double? radius;
  final List<TextInputFormatter>? inputFormatters;
  final double? lineHeight;
  final EdgeInsets? contentPadding;
  final OutlineInputBorder? border;
  final OutlineInputBorder? disabledBorder;
  final UnderlineInputBorder? underLineborder;
  final FocusNode? focusNode;
  final bool? autoFocus;
  final bool? enabled;

  const AppTextField({
    super.key,
    this.isCollapsed,
    this.initialValue,
    this.keyboardType,
    this.autoValidateMode,
    this.focusNode,
    this.textInputAction,
    this.textController,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.onTap,
    this.onSubmitted,
    this.errorText,
    this.textColor,
    this.fontWeight,
    this.obscureText,
    this.suffix,
    this.textDecoration,
    this.textDecorationStyle,
    this.textDecorationColor,
    this.font,
    this.textAlign,
    this.lineHeight,
    this.validator,
    this.readOnly,
    this.maxLength,
    this.onChanged,
    this.textBorderColor,
    this.contentPadding,
    this.textColorHint,
    this.fillColor,
    this.minLines,
    this.fontSize,
    this.maxLines,
    this.border,
    this.disabledBorder,
    this.underLineborder,
    this.inputFormatters,
    this.radius,
    this.autoFocus,
    this.enabled,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      initialValue: initialValue,
      textAlignVertical: TextAlignVertical.center,
      autofocus: autoFocus ?? false,
      focusNode: focusNode,
      keyboardType: keyboardType,
      readOnly: readOnly ?? false,
      textAlign: textAlign ?? TextAlign.start,
      enabled: enabled ?? true,
      maxLength: maxLength,
      minLines: minLines,
      maxLines: maxLines ?? 1,
      autovalidateMode: autoValidateMode,
      validator: validator,
      textInputAction: textInputAction,
      onTap: onTap,
      onChanged: onChanged,
      obscureText: obscureText ?? false,
      controller: textController,
      onFieldSubmitted: onSubmitted,
      inputFormatters: inputFormatters ?? [],
      cursorColor: AppColors.primary,
      style: textStyle != null
          ? textStyle!.copyWith(
              color: textColor ?? Colors.black,
              height: lineHeight ?? 1.5,
              decoration: textDecoration ?? TextDecoration.none,
              decorationStyle: textDecorationStyle ?? TextDecorationStyle.solid,
              decorationColor: textDecorationColor ?? Colors.transparent,
            )
          : TextStyle(
              color: textColor ?? AppColors.textBody,
              fontFamily: font ?? AppFonts.pretendard,
              fontSize: fontSize ?? 14,
              fontWeight: fontWeight ?? FontWeight.w400,
              letterSpacing: 0.02,
              height: lineHeight ?? 1.5,
              decoration: textDecoration ?? TextDecoration.none,
              decorationStyle: textDecorationStyle ?? TextDecorationStyle.solid,
              decorationColor: textDecorationColor ?? Colors.transparent,
            ),
      decoration: InputDecoration(
        isCollapsed: isCollapsed ?? false,
        errorStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.error,
        ),
        enabledBorder: underLineborder ??
            border ??
            OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.borderDefault),
              borderRadius: BorderRadius.circular(radius ?? AppRadius.md),
            ),
        disabledBorder: disabledBorder ??
            OutlineInputBorder(
              borderSide: BorderSide(color: Colors.transparent, width: 0),
              borderRadius: BorderRadius.circular(radius ?? AppRadius.md),
            ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.error),
          borderRadius: BorderRadius.circular(radius ?? AppRadius.md),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(color: AppColors.error),
          borderRadius: BorderRadius.circular(radius ?? AppRadius.md),
        ),
        focusedBorder: readOnly ?? false
            ? OutlineInputBorder(
                borderSide: BorderSide(color: AppColors.primary),
                borderRadius: BorderRadius.circular(radius ?? AppRadius.md),
              )
            : underLineborder ??
                border ??
                OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.primary),
                  borderRadius: BorderRadius.circular(radius ?? AppRadius.md),
                ),
        border: underLineborder ??
            border ??
            OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.borderDefault),
              borderRadius: BorderRadius.circular(radius ?? AppRadius.md),
            ),
        fillColor: fillColor ??
            (readOnly ?? false ? AppColors.surfaceSunken : AppColors.surfaceCard),
        filled: true,
        hintText: hintText,
        suffix: suffix,
        errorText: errorText,
        hintStyle: TextStyle(
          fontFamily: font ?? AppFonts.pretendard,
          color: textColorHint ?? AppColors.textSubtle,
          fontSize: fontSize ?? 14,
          fontWeight: FontWeight.w300,
          letterSpacing: 0.02,
          height: lineHeight ?? 1.5,
          decoration: textDecoration ?? TextDecoration.none,
          decorationStyle: textDecorationStyle ?? TextDecorationStyle.solid,
          decorationColor: textDecorationColor ?? Colors.transparent,
        ),
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        counterText: '',
        suffixIconConstraints: BoxConstraints(maxHeight: double.maxFinite),
        contentPadding: contentPadding ??
            EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.md),
      ),
    );
  }
}
