import 'package:flutter/material.dart';
import 'package:picsong/presentation/design_system/components/text/app_text.dart';
import 'package:picsong/presentation/design_system/components/layout/gap.dart';
import 'package:picsong/presentation/design_system/foundation/app_spacing.dart';

/// 아이콘과 텍스트가 컬럼으로 배치된 버튼
class IconTextColumnButton extends StatelessWidget {
  const IconTextColumnButton({
    super.key,
    required this.iconPath,
    required this.title,
    required this.onTapped,
  });

  final String iconPath;
  final String title;
  final VoidCallback onTapped;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapped,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            iconPath,
            width: 28,
            height: 28,
          ),
          const Gap(height: AppSpacing.sm),
          AppText(
            text: title,
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ],
      ),
    );
  }
}
