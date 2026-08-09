import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/image_paths.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';

enum BackButtonType {
  xmark(iconPath: ImagePaths.close),
  arrowLeft(iconPath: ImagePaths.arrowLeft);

  final String iconPath;

  const BackButtonType({required this.iconPath});
}

class DefaultAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Color? titleColor;
  final bool centerTitle;
  final Color? backButtonColor;
  final double fontSize;
  final List<Widget>? actions;

  final Color? backgroundColor;

  final double? leadingWidth;
  final Widget? leadingWidget; // 왼쪽 아이콘입니다. isShowBackButton이 false일 경우 표시합니다.
  final bool isShowBackButton;
  final BackButtonType backButtonType;
  final VoidCallback? onBackTapped;

  const DefaultAppBar({
    super.key,
    required this.title,
    this.titleColor,
    this.centerTitle = false,
    this.backButtonColor,
    this.fontSize = 18,
    this.actions,
    this.onBackTapped,
    this.isShowBackButton = true,
    this.backgroundColor = Colors.white,
    this.leadingWidth,
    this.leadingWidget,
    this.backButtonType = BackButtonType.arrowLeft,
  });

  @override
  Widget build(BuildContext context) {
    final appBarTheme = Theme.of(context).appBarTheme;

    return AppBar(
      centerTitle: centerTitle,
      toolbarHeight: 56,
      surfaceTintColor: backgroundColor,
      backgroundColor: backgroundColor,
      titleSpacing: -10,
      title: AppText(text: title, fontSize: fontSize, color: titleColor),
      leadingWidth: leadingWidth,
      leading: isShowBackButton
          ? _buildBackButton(
              context,
              backButtonColor ?? appBarTheme.titleTextStyle?.color,
            )
          : leadingWidget ?? const Gap(width: 10),
      actions: actions,
    );
  }

  ///
  /// 뒤로가기 버튼 구성
  ///
  Widget _buildBackButton(BuildContext context, Color? color) {
    switch (backButtonType) {
      case BackButtonType.xmark:
        return IconButton(
          icon: Image.asset(
            ImagePaths.close,
            width: 16,
            height: 16,
            color: color,
          ),
          onPressed: onBackTapped ?? () => Navigator.of(context).pop(),
        );
      case BackButtonType.arrowLeft:
        return IconButton(
          icon: Image.asset(
            ImagePaths.arrowLeft,
            width: 24,
            height: 24,
            color: color,
          ),
          onPressed: onBackTapped ?? () => Navigator.of(context).pop(),
        );
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
