import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/foundation/app_fonts.dart';

class AppText extends StatelessWidget {
  final TextDecoration? textDecoration;
  final String text;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final String? fontFamily;
  final TextAlign? textAlign;
  final FontStyle? fontStyle;
  final TextOverflow? overflow;
  final int? maxLines;
  final double? height;
  final double? letterSpacing;
  /// 타이포그래피 프리셋(베이스). 개별 파라미터가 있으면 그 값으로 덮어쓴다.
  final TextStyle? style;

  const AppText({
    super.key,
    required this.text,
    this.color,
    this.fontFamily,
    this.height,
    this.textAlign,
    this.overflow = TextOverflow.ellipsis,
    this.maxLines,
    this.fontSize,
    this.fontStyle,
    this.fontWeight,
    this.letterSpacing,
    this.textDecoration,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      overflow: overflow,
      maxLines: maxLines,
      style: _resolveStyle(),
    );
  }

  ///
  /// style 프리셋이 있으면 베이스로 삼아 개별 파라미터만 덮어쓰고,
  /// 없으면 기존 기본값으로 스타일을 구성한다.
  ///
  TextStyle _resolveStyle() {
    final TextStyle? preset = style;
    if (preset != null) {
      return preset.copyWith(
        height: height,
        decoration: textDecoration,
        decorationColor: color,
        fontFamily: fontFamily,
        fontSize: fontSize,
        letterSpacing: letterSpacing,
        fontStyle: fontStyle,
        fontWeight: fontWeight,
        color: color,
      );
    }
    return TextStyle(
      height: height ?? 1.4,
      decoration: textDecoration ?? TextDecoration.none,
      decorationColor: color ?? AppColors.appBlack,
      fontFamily: fontFamily ?? AppFonts.pretendard,
      fontSize: fontSize ?? 14,
      letterSpacing: letterSpacing ?? -0.48,
      fontStyle: fontStyle ?? FontStyle.normal,
      fontWeight: fontWeight ?? FontWeight.w700,
      color: color ?? AppColors.gray800,
    );
  }
}
