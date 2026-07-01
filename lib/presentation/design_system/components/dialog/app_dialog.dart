import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/foundation/app_colors.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';
import 'package:picsong/presentation/design_system/foundation/app_radius.dart';

class AppDialog extends Dialog {
  const AppDialog({
    super.key,
    this.isDoubleButton = false, // 버튼을 분할 형식으로 표시할지 여부
    this.subTitle, // 부제목 텍스트
    this.onLeftButtonTapped, // 왼쪽 버튼 클릭 콜백
    this.leftButtonText, // 왼쪽 버튼 텍스트
    this.leftButtonColor = AppColors.primary50,
    this.rightButtonColor = AppColors.primary,
    this.image,
    this.midContent,
    required this.rightButtonText, // 오른쪽 버튼 텍스트
    required this.onRightButtonTapped, // 오른쪽 버튼 클릭 콜백
    required this.title, // 제목 텍스트
  });

  /// 단일 버튼 형식의 다이얼로그 생성자
  factory AppDialog.singleButton({
    required String title,
    required VoidCallback onButtonTapped,
    String? subTitle,
    Color? btnColor,
    String? midContent,
    required String btnContent,
    Image? image,
  }) =>
      AppDialog(
        title: title,
        subTitle: subTitle,
        onRightButtonTapped: onButtonTapped,
        rightButtonText: btnContent,
        midContent: midContent,
        rightButtonColor: btnColor ?? AppColors.primary,
        image: image,
      );

  /// 분할 버튼 형식의 다이얼로그 생성자
  factory AppDialog.doubleButton({
    required String title,
    String? subTitle,
    required String leftButtonContent,
    required String rightButtonContent,
    Color? leftButtonColor,
    Color? rightButtonColor,
    required VoidCallback onRightButtonTapped,
    required VoidCallback onLeftButtonTapped,
    Image? image,
  }) =>
      AppDialog(
        isDoubleButton: true,
        title: title,
        subTitle: subTitle,
        onRightButtonTapped: onRightButtonTapped,
        onLeftButtonTapped: onLeftButtonTapped,
        leftButtonText: leftButtonContent,
        rightButtonText: rightButtonContent,
        leftButtonColor: leftButtonColor ?? AppColors.primary50,
        rightButtonColor: rightButtonColor ?? AppColors.primary,
        image: image,
      );

  final bool isDoubleButton;
  final String title;
  final VoidCallback onRightButtonTapped;
  final VoidCallback? onLeftButtonTapped;
  final String? rightButtonText;
  final String? leftButtonText;
  final String? subTitle;
  final Color leftButtonColor;
  final Color rightButtonColor;
  final Image? image;
  final String? midContent;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        padding: const EdgeInsets.only(top: AppSpacing.xxxl, left: AppSpacing.xl, right: AppSpacing.xl, bottom: AppSpacing.xl),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.sheet),
          color: Colors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (image != null) ...[
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                child: image!,
              ),
            ],

            /// Title
            AppText(
              text: title,
              textAlign: TextAlign.center,
              fontSize: 24,
              color: AppColors.gray900,
            ),

            /// Sub Title
            if (subTitle != null) ...[
              const Gap(height: AppSpacing.xl),
              AppText(
                text: subTitle!,
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.gray900,
                textAlign: TextAlign.center,
                overflow: TextOverflow.visible,
                maxLines: 10,
              ),
            ],

            if (midContent != null)
              Container(
                  width: double.maxFinite,
                  margin: const EdgeInsets.only(top: AppSpacing.xl),
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 10),
                  decoration: BoxDecoration(
                      color: AppColors.gray100,
                      borderRadius: BorderRadius.circular(AppRadius.lg)),
                  child: Center(
                    child: AppText(
                      text: midContent!,
                      fontSize: 20,
                      fontWeight: FontWeight.w400,
                      color: AppColors.gray600,
                    ),
                  )),

            // Buttons
            const Gap(height: AppSpacing.xxxl),
            Row(
              children: [
                if (isDoubleButton) ...[
                  Expanded(
                    child: _buildButton(
                      text: leftButtonText!,
                      onTapped: onLeftButtonTapped ?? () {},
                      color: leftButtonColor,
                      textColor: AppColors.primary,
                    ),
                  ),
                  const Gap(width: AppSpacing.md),
                ],
                Expanded(
                  child: _buildButton(
                    text: rightButtonText!,
                    onTapped: onRightButtonTapped,
                    color: rightButtonColor,
                    textColor: AppColors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required Color color,
    required VoidCallback onTapped,
    required Color textColor,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTapped,
      child: Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Center(
          child: AppText(
            text: text,
            fontSize: 16,
            color: textColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
